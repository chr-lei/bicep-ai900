// Define parameters

param resourceGroupLocation string = resourceGroup().location

@description('Identifier string for naming resources uniquely. Will be used as a prefix/suffix in resource names as appropriate.')
param uniqueName string

// Create Resources
//
// Storage Accounts for:
// AI Search
resource storageAccountSearch 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'st${uniqueName}search'
  location: resourceGroupLocation
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
}


// AI Services
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
    publicNetworkAccess: 'Enabled'
  }
  identity: {
    type: 'SystemAssigned'
  }
}
