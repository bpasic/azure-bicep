param location string
param appServiceAppName string

@allowed([
  'dev'
  'prod'
])
param environmentType string

var appServicePlanName = 'bptoyplan'
var appServicePlanSkuName = (environmentType == 'prod') ? 'P2_v3' : 'F1'
var appServicePlanTierName = (environmentType == 'prod') ? 'PremiumV3' : 'Free'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
    tier: appServicePlanTierName
    capacity: 1
  }
}

resource appServiceApp 'Microsoft.Web/sites@2020-12-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
