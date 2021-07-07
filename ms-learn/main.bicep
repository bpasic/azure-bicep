param location string = resourceGroup().location
param storageAccountName string = 'bptoy${uniqueString(resourceGroup().id)}'
param appServiceAppName string = 'bptoy${uniqueString(resourceGroup().id)}'

@allowed([
  'dev'
  'prod'
])
param environmentType string

var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSkuName
    tier: 'Standard'
  }
}

module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    location: location
    environmentType: environmentType
    appServiceAppName: appServiceAppName
  } 
}

output appServiceHostName string = appService.outputs.appServiceAppHostName
