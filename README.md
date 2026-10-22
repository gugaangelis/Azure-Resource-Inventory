# Azure-Resource-Inventory
Cria um agente no Azure AI Foundry para realizar assessment no seu ambiente Azure e fazer um inventário geral, com recomendações de segurança, finops



# 📊 Azure Inventory com Azure AI Foundry

Este projeto realiza o inventário de recursos no Azure utilizando integração com o Azure AI Foundry.

---

## 🚀 1. Criando um Projeto no Azure AI Foundry

### Passo a passo

1. Acesse o portal:
   - https://ai.azure.com

2. Clique em **"Create Project"**

3. Preencha os campos:
   - **Project Name**
   - **Resource Group**
   - **Region**

4. Clique em **Create**

---

### 🔑 Obtendo a URL e a Key

Após criar o projeto:

1. Acesse o projeto criado
2. Vá até **Settings** ou **Keys and Endpoint**
3. Copie:
   - **Endpoint (URL)**
   - **API Key**

Exemplo:

ENDPOINT=https://seu-projeto.openai.azure.com/  
API_KEY=xxxxxxxxxxxxxxxxxxxxxxxx  

---

## ⚙️ 2. Ajuste no Script PowerShell

Abra o arquivo:

Script_Inventory.ps1

Localize as linhas:

$endpoint = ""
$apiKey = ""

Substitua pelos valores obtidos:

$endpoint = "https://seu-projeto.openai.azure.com/"
$apiKey = "SUA_API_KEY_AQUI"

---

## ▶️ 3. Execução do Script

### Pré-requisitos

- PowerShell 7+
- Azure CLI instalado
- Usuário autenticado no Azure

---

### 🔐 Login no Azure

az login

Caso tenha múltiplas subscriptions:

az account set --subscription "<SUBSCRIPTION_ID>"

---

### ▶️ Executando o Script

No diretório onde está o script:

pwsh ./Script_Inventory.ps1

---

### 📁 Saída esperada

O script irá:

- Consultar recursos via Azure Resource Graph
- Processar os dados
- Enviar/interpretar via Azure AI Foundry
- Gerar saída estruturada (JSON / relatório)

---

## 🧠 Observações

- Certifique-se de que a Key e Endpoint estão corretos
- Verifique permissões no Azure (Reader ou superior)
- Em caso de erro, valide:
  - Conectividade
  - Autenticação
  - Permissões do recurso

---

## 📌 Estrutura do Projeto

.
├── Script_Inventory.ps1
└── README.md

---

## ✅ Próximos Passos

- Automatizar via pipeline (Azure DevOps / GitHub Actions)
- Armazenar resultados em Storage Account ou Log Analytics
- Integrar com dashboards (Power BI / Grafana)
