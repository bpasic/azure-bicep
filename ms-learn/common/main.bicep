// PARAMETERS
@description('Azure region where resources are deployed.')
param location string = resourceGroup().location

@description('Type of the environment deployed')
param storageAccountName string = 'bptoy${uniqueString(resourceGroup().id)}'

@description('Type of the environment deployed, must be dev or prod.')
@allowed([
  'dev'
  'prod'
])
param environmentType string

@description('The unique name of the solution. This is used to ensure that resource names are unique.')
@minLength(5)
@maxLength(30)
param solutionName string = 'bptoy${uniqueString(resourceGroup().id)}'

@description('The number of App Service plan instances.')
@minValue(1)
@maxValue(3)
param appServicePlanInstanceCount int

@description('Storage account names used for Copy loop')
param storageAccountNames array = [
  'bpsa1337aa'
  'bpsa1337bb'
  'bpsa1337cc'
]

// VARIABLES
var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'
var appServicePlanName = '${environmentType}-${solutionName}-plan'
var appServiceAppName = '${environmentType}-${solutionName}-app'

// RESOURCES
resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = if (environmentType == 'prod') {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSkuName
    tier: 'Standard'
  }
}

// Copy loop based on array
resource storageaccountsarray 'Microsoft.Storage/storageAccounts@2021-02-01' = [for storageAccountName in storageAccountNames: {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSkuName
    tier: 'Standard'
  }
}]

// Copy loop based on count/range
resource storageaccountscount 'Microsoft.Storage/storageAccounts@2021-02-01' = [for i in range(1,3): {
  name: 'bpsa1337${i}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSkuName
    tier: 'Standard'
  }
}]

// MODULES
module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    location: location
    environmentType: environmentType
    appServicePlanName: appServicePlanName
    appServiceAppName: appServiceAppName
    appServicePlanInstanceCount: appServicePlanInstanceCount
  } 
}

// OUTPUTS
output appServiceHostName string = appService.outputs.appServiceAppHostName
