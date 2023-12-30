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

// Azure Machine Learning Workspace Resources
module azureMachineLearningWorkspace 'mlworkspace.bicep' = {
  name: '${resource_name_seed}-amlwDeploy'
  scope: resourceGroup
  params: {
    nameSeed: resource_name_seed
    location: resourceGroup.location
    tenantId: tenant().tenantId
  }
}

// Outputs
output resource_name_seed string = resource_name_seed
output azure_machine_learning_workspace_url string = azureMachineLearningWorkspace.outputs.amlw_url
