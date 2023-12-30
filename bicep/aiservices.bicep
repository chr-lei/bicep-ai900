param nameSeed string
param identifier int = 01
param location string
param ai_services_sku string = 'S0'
param ai_language_sku string = 'F0'
param doc_intelligence_sku string = 'F0'
param search_service_id string

// Calculate resource names
var ai_services_name = '${nameSeed}aiservice${identifier}'
var ai_language_name = '${nameSeed}ailanguage${identifier}'
var doc_intelligence_name = '${nameSeed}aidoc${identifier}'

// Azure AI Multi-Service Resource
resource AIServices 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: ai_services_name
  location: location
  sku: { name: ai_services_sku }
  kind: 'CognitiveServices'
  properties: {
    customSubDomainName: ai_services_name
    publicNetworkAccess: 'Enabled'
  }
}

// Azure AI Language
resource AILanguage 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: ai_language_name
  location: location
  sku: { name: ai_language_sku }
  kind: 'TextAnalytics'
  properties: {
    apiProperties: {
      qnaAzureSearchEndpointId: search_service_id
    }
    customSubDomainName: ai_language_name
    publicNetworkAccess: 'Enabled'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Azure Document Intelligence
resource documentIntelligence 'Microsoft.CognitiveServices/accounts@2021-04-30' = {
  name: doc_intelligence_name
  location: location
  sku: { name: doc_intelligence_sku }
  kind: 'FormRecognizer'
  properties: {
    customSubDomainName: doc_intelligence_name
    publicNetworkAccess: 'Enabled'
  }
}
