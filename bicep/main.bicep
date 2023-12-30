// Define parameters

param resourceGroupLocation string = resourceGroup().location

@description('Identifier string for naming resources uniquely. Will be used as a prefix/suffix in resource names as appropriate.')
param uniqueName string

// Define variables
var amlw_resource_name_seed = '${uniqueName}${uniqueString(resourceGroup().id, 'amlw')}'

// Create Resources
//
// Storage Accounts for:
// AI Search
resource storageAccountSearch 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${uniqueName}search'
  location: resourceGroupLocation
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
}


// AI Services:
// Search
resource serviceSearch 'Microsoft.Search/searchServices@2020-08-01' = {
  name: '${uniqueName}search'
  location: resourceGroupLocation
  sku: { name: 'free' }
  properties: { 
    publicNetworkAccess: 'enabled'
  }
}

// Azure AI Services multi-service account
resource serviceAIServices 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: '${uniqueName}aiservice01'
  location: resourceGroupLocation
  sku: { name: 'S0' }
  kind: 'CognitiveServices'
  properties: {
    customSubDomainName: '${uniqueName}aiservice01'
    publicNetworkAccess: 'Enabled'
  }
}

// Azure AI Language service
resource serviceAILanguage 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: '${uniqueName}language01'
  location: resourceGroupLocation
  sku: { name: 'F0' }
  kind: 'TextAnalytics'
  properties: {
    apiProperties: {
      qnaAzureSearchEndpointId: serviceSearch.id
    }
    customSubDomainName: '${uniqueName}language01'
    publicNetworkAccess: 'Enabled'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Azure Document Intelligence
resource serviceDocumentIntelligence 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: '${uniqueName}doc01'
  location: resourceGroupLocation
  sku: { name: 'F0' }
  kind: 'FormRecognizer'
  properties: {
    customSubDomainName: '${uniqueName}doc01'
    publicNetworkAccess: 'Enabled'
  }
}

// Azure Machine Learning Workspace Resources
// Storage Account
resource amlw_storage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: amlw_resource_name_seed
  location: resourceGroupLocation
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    supportsHttpsTrafficOnly: true
  }
}

// Key Vault
resource amlw_key_vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: amlw_resource_name_seed
  location: resourceGroupLocation
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
  }
}

// Application Insights
resource amlw_app_insights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: amlw_resource_name_seed
  location: resourceGroupLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

// Workspace
resource amlw_workspace 'Microsoft.MachineLearningServices/workspaces@2020-08-01' = {
  name: '${uniqueName}aml01'
  location: resourceGroupLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: '${uniqueName}aml01'
    storageAccount: amlw_storage.id
    keyVault: amlw_key_vault.id
    applicationInsights: amlw_app_insights.id
  }
}

// Key Vault Access Policy
resource amlw_key_vault_policy 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  parent: amlw_key_vault
  name: 'replace'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: amlw_workspace.identity.principalId
        permissions: {
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
          certificates: [
            'all'
          ]
          storage: []
        }
      }
    ]
  }
}

// Outputs
output amlw_resource_name_seed string = amlw_resource_name_seed
