param nameSeed string
param identifier int = 01
param location string
param tenantId string

// Calculate resource names
var storageAccountName = 'st${nameSeed}amlw${identifier}'
var keyvaultName = 'kv${nameSeed}amlw${identifier}'
var appInsightsName = 'appins${nameSeed}amlw${identifier}'
var workspaceName = nameSeed

// Storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

// Key vault
// Note: access policy is configured during the creation of the AMLW by the service.
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyvaultName
  location: location
  properties: {
    tenantId: tenantId
    accessPolicies: []
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

// App Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

// Azure Machine Learning Workspace
// Note: the service will attempt to configure access to vaults and storage accounts during provisioning.
resource workspace 'Microsoft.MachineLearningServices/workspaces@2020-08-01' = {
    name: workspaceName
    location: location
    identity: {
      type: 'SystemAssigned'
    }
    properties: {
      friendlyName: workspaceName
      storageAccount: storageAccount.id
      keyVault: keyVault.id
      applicationInsights: appInsights.id
    }
  }

output amlw_url string = 'https://ml.azure.com?tid=${tenantId}&wsid=${workspace.id}'
