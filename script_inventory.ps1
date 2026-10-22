# =============================================
# IA que documenta sua infra Azure
# Com Mermaid e publicacao no GitHub
# Raphael Andrade - TFTEC Cloud
# =============================================

# PRE-REQUISITOS (somente na primeira vez):
# Install-Module -Name Az.ResourceGraph -Force -Scope CurrentUser
# winget install --id GitHub.cli
# gh auth login

# 1. Conectar no Azure
Connect-AzAccount

# 2. Buscar TODOS os recursos em uma unica query
$query = @"
Resources
| project name, type, location, resourceGroup
| order by type asc
"@

Write-Host "Inventariando ambiente Azure..." -ForegroundColor Cyan
$recursos   = Search-AzGraph -Query $query -First 500
Write-Host "Encontrados: $($recursos.Count) recursos" -ForegroundColor Green
$inventario = $recursos | ConvertTo-Json -Depth 2

# 3. Configurar AI Foundry
$endpoint = "URL-DO-SEU-ENDPOINT" # Exemplo: https://meu-recurso.cognitiveservices.azure.com
$apiKey   = "APIKEY-AQUI" # Substitua pela sua chave de API
$deploy   = "gpt-5.4-mini"
$url      = "$endpoint/openai/deployments/$deploy/chat/completions?api-version=2024-12-01-preview"

$client = New-Object System.Net.Http.HttpClient
$client.DefaultRequestHeaders.Add("api-key", $apiKey)

# 4. Gerar documentacao tecnica
Write-Host "Gerando documentacao com IA..." -ForegroundColor Cyan
$bodyDoc = @{
    messages = @(
        @{ role = "system"; content = "Voce e um arquiteto Azure senior. Analise o inventario e gere documentacao tecnica completa em portugues. Organize por tipo de recurso, identifique padroes de arquitetura, aponte riscos e boas praticas nao seguidas." },
        @{ role = "user";   content = "Inventario do ambiente Azure:`n`n$inventario`n`nGere um documento de arquitetura completo." }
    )
    temperature           = 0.3
    max_completion_tokens = 25000
} | ConvertTo-Json -Depth 5
$respDoc      = $client.PostAsync($url, (New-Object System.Net.Http.StringContent($bodyDoc, [System.Text.Encoding]::UTF8, "application/json"))).Result
$jsonDoc      = $respDoc.Content.ReadAsStringAsync().Result | ConvertFrom-Json
$documentacao = $jsonDoc.choices[0].message.content
Write-Host "Documentacao gerada — tokens: $($jsonDoc.usage.total_tokens)" -ForegroundColor Green

# 5. Gerar diagrama Mermaid
Write-Host "Gerando diagrama Mermaid..." -ForegroundColor Cyan
$bodyMermaid = @{
    messages = @(
        @{ role = "system"; content = "Voce e um arquiteto Azure. Gere um diagrama Mermaid usando 'flowchart LR' do ambiente. Regras obrigatorias: (1) crie um subgraph para CADA resource group existente no inventario — todos devem aparecer, (2) dentro de cada subgraph inclua no maximo 3 recursos, priorizando os mais importantes: VMs, App Services, Databases, Storage Accounts, VNets — se o RG tiver so recursos auxiliares, coloque o mais representativo, (3) ignore completamente: Managed Identities, Diagnostic Settings, Action Groups e Public IPs, (4) conecte recursos que se relacionam logicamente entre RGs quando houver relacao evidente. Retorne SOMENTE o bloco mermaid, comecando com \`\`\`mermaid e terminando com \`\`\`." },
        @{ role = "user";   content = "Inventario Azure:`n`n$inventario`n`nGere o diagrama Mermaid com todos os resource groups." }
    )
    temperature           = 0.1
    max_completion_tokens = 8000
} | ConvertTo-Json -Depth 5
$respMermaid = $client.PostAsync($url, (New-Object System.Net.Http.StringContent($bodyMermaid, [System.Text.Encoding]::UTF8, "application/json"))).Result
$jsonMermaid = $respMermaid.Content.ReadAsStringAsync().Result | ConvertFrom-Json
$diagrama    = $jsonMermaid.choices[0].message.content
Write-Host "Diagrama gerado — tokens: $($jsonMermaid.usage.total_tokens)" -ForegroundColor Green

# 6. Montar e salvar o arquivo .md
$arquivo = "documentacao-azure-$(Get-Date -Format 'yyyy-MM-dd').md"
$conteudo = @"
$documentacao

---

## Diagrama de Arquitetura

$diagrama
"@
$conteudo | Out-File -FilePath $arquivo -Encoding UTF8
Write-Host "Arquivo salvo: $arquivo" -ForegroundColor Green

# 7. Publicar no GitHub
$repoLocal  = "C:\repos\azure-ai-inventory"
$repoGitHub = "raphasi/azure-ai-inventory"

if (-not (Test-Path "$repoLocal\.git")) {
    Write-Host "Configurando repositorio local..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $repoLocal -Force | Out-Null
    Set-Location $repoLocal
    git init -b main
    git remote add origin "https://github.com/$repoGitHub.git"
    git pull origin main
    Set-Location $env:USERPROFILE
}

New-Item -ItemType Directory -Path "$repoLocal\docs" -Force | Out-Null
Copy-Item $arquivo "$repoLocal\docs\$arquivo" -Force

Set-Location $repoLocal
git add .
git commit -m "docs: documentacao Azure $(Get-Date -Format 'yyyy-MM-dd') [$($recursos.Count) recursos]"
git push origin main
Set-Location $env:USERPROFILE

$repoUrl = gh repo view $repoGitHub --json url -q ".url"
Write-Host "Publicado em: $repoUrl/blob/main/docs/$arquivo" -ForegroundColor Green