param nameSeed string
param identifier int = 01
param location string
param storage_sku string = 'Standard_LRS'
param search_sku string = 'free'

// Calculate resource names
var storageAccountName = 'st${nameSeed}search${identifier}'
var searchServiceName = 'svc${nameSeed}search${identifier}'

resource storageAaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: { name: storage_sku }
}

resource serviceSearch 'Microsoft.Search/searchServices@2020-08-01' = {
  name: searchServiceName
  location: location
  sku: { name: search_sku }
  properties: {
    publicNetworkAccess: 'enabled'
  }
}

output searchServiceId string = serviceSearch.id
