// Define parameters

@description('Location for the learning resource group and all child resources.')
param resourceGroupLocation string = 'eastus'

@description('Identifier string for naming resources uniquely. Will be used as a prefix/suffix in resource names as appropriate. 6 - 13')
@minLength(3)
@maxLength(10)
param identifier string

// Define variables
var resource_name_seed = '${identifier}${uniqueString(subscription().id, 'amlw')}'

// Create Resources
//
// Storage Accounts for:
// AI Search
resource storageAccountSearch 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${identifier}search'
  location: resourceGroupLocation
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
}


// AI Services:
// Search
resource serviceSearch 'Microsoft.Search/searchServices@2020-08-01' = {
  name: '${identifier}search'
  location: resourceGroupLocation
  sku: { name: 'free' }
  properties: { 
    publicNetworkAccess: 'enabled'
  }
}

// Azure AI Services multi-service account
resource serviceAIServices 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: '${identifier}aiservice01'
  location: resourceGroupLocation
  sku: { name: 'S0' }
  kind: 'CognitiveServices'
  properties: {
    customSubDomainName: '${identifier}aiservice01'
    publicNetworkAccess: 'Enabled'
  }
}

// Azure AI Language service
resource serviceAILanguage 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: '${identifier}language01'
  location: resourceGroupLocation
  sku: { name: 'F0' }
  kind: 'TextAnalytics'
  properties: {
    apiProperties: {
      qnaAzureSearchEndpointId: serviceSearch.id
    }
    customSubDomainName: '${identifier}language01'
    publicNetworkAccess: 'Enabled'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Azure Document Intelligence
resource serviceDocumentIntelligence 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: '${identifier}doc01'
  location: resourceGroupLocation
  sku: { name: 'F0' }
  kind: 'FormRecognizer'
  properties: {
    customSubDomainName: '${identifier}doc01'
    publicNetworkAccess: 'Enabled'
  }
}

// Azure Machine Learning Workspace Resources
// Storage Account
resource amlw_storage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: resource_name_seed
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
  name: resource_name_seed
  location: resourceGroupLocation
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
  }

  resource amlw_key_vault_policy 'accessPolicies' = {
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
}

// Application Insights
resource amlw_app_insights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: resource_name_seed
  location: resourceGroupLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

// Workspace
resource amlw_workspace 'Microsoft.MachineLearningServices/workspaces@2020-08-01' = {
  name: '${identifier}aml01'
  location: resourceGroupLocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: '${identifier}aml01'
    storageAccount: amlw_storage.id
    keyVault: amlw_key_vault.id
    applicationInsights: amlw_app_insights.id
  }
}

// Outputs
output resource_name_seed string = resource_name_seed
