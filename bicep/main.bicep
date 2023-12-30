// Set scope to subscription.
targetScope = 'subscription'

// Define parameters

@description('Location for the learning resource group and all child resources.')
param resourceGroupLocation string = 'eastus'

@description('Name string for naming resources uniquely. Will be used as a prefix/suffix in resource names as appropriate. 6 - 13')
@minLength(3)
@maxLength(10)
param nameString string

// Define variables
var resource_name_seed = '${nameString}${take(uniqueString(subscription().id, resourceGroup.id, 'amlw'), 6)}'

// Create a resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${nameString}'
  location: resourceGroupLocation
}

// Create Resources
//
// AI Search
module AISearch 'search.bicep' = {
  name: '${resource_name_seed}-searchDeploy'
  scope: resourceGroup
  params: {
    nameSeed: resource_name_seed
    location: resourceGroup.location
  }
}

// AI Services
module AIServices 'aiservices.bicep' = {
  name: '${resource_name_seed}-servicesDeploy'
  scope: resourceGroup
  params: {
    nameSeed: resource_name_seed
    location: resourceGroup.location
    search_service_id: AISearch.outputs.searchServiceId
  }
}

// // Azure Machine Learning Workspace Resources
// // Storage Account
// resource amlw_storage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
//   name: resource_name_seed
//   location: resourceGroupLocation
//   sku: { name: 'Standard_LRS' }
//   kind: 'StorageV2'
//   properties: {
//     encryption: {
//       services: {
//         blob: {
//           enabled: true
//         }
//         file: {
//           enabled: true
//         }
//       }
//       keySource: 'Microsoft.Storage'
//     }
//     supportsHttpsTrafficOnly: true
//   }
// }

// // Key Vault
// resource amlw_key_vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
//   name: resource_name_seed
//   location: resourceGroupLocation
//   properties: {
//     sku: {
//       name: 'standard'
//       family: 'A'
//     }
//     tenantId: subscription().tenantId
//     accessPolicies: []
//   }

//   resource amlw_key_vault_policy 'accessPolicies' = {
//     name: 'replace'
//     properties: {
//       accessPolicies: [
//         {
//           tenantId: subscription().tenantId
//           objectId: amlw_workspace.identity.principalId
//           permissions: {
//             keys: [
//               'all'
//             ]
//             secrets: [
//               'all'
//             ]
//             certificates: [
//               'all'
//             ]
//             storage: []
//           }
//         }
//       ]
//     }
//   }
// }

// // Application Insights
// resource amlw_app_insights 'Microsoft.Insights/components@2020-02-02-preview' = {
//   name: resource_name_seed
//   location: resourceGroupLocation
//   kind: 'web'
//   properties: {
//     Application_Type: 'web'
//   }
// }

// // Workspace
// resource amlw_workspace 'Microsoft.MachineLearningServices/workspaces@2020-08-01' = {
//   name: '${nameString}aml01'
//   location: resourceGroupLocation
//   identity: {
//     type: 'SystemAssigned'
//   }
//   properties: {
//     friendlyName: '${nameString}aml01'
//     storageAccount: amlw_storage.id
//     keyVault: amlw_key_vault.id
//     applicationInsights: amlw_app_insights.id
//   }
// }

// Outputs
output resource_name_seed string = resource_name_seed
