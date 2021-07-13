param cosmosDBAccountName string = 'toyrnd-${uniqueString(resourceGroup().id)}'
param cosmosDBDatabaseThroughput int = 400
var cosmosDBDatabaseName = 'FlightTests'
var cosmosDBContainerName = 'FlightTests'
var cosmosDBContainerPartitionKey = '/droneId'

param location string = resourceGroup().location

// CHILD RESOURCES
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2020-04-01' = {
  name: cosmosDBAccountName
  location: location
  properties: {
    locations: [
      {
        locationName: location
      }
    ]
    databaseAccountOfferType: 'Standard'
  }
}

resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2020-04-01' = {
  parent: cosmosDbAccount
  name: cosmosDBDatabaseName
  properties: {
    resource: {
      id: cosmosDBDatabaseName
    }
    options: {
      throughput: cosmosDBDatabaseThroughput
    }
  }

  resource container 'containers' = {
    name: cosmosDBContainerName
    properties: {
      resource: {
        id: cosmosDBContainerName
        partitionKey: {
          kind: 'Hash'
          paths: [
            cosmosDBContainerPartitionKey
          ]
        }
      }
      options: {}
    }
  }
}

// EXTENSION RESOURCES
resource lockResource 'Microsoft.Authorization/locks@2016-09-01' = {
  scope: cosmosDbAccount
  name: 'DoNotDelete'
  properties: {
    level: 'CanNotDelete'
  }
}

