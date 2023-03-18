@description('The suffix to be used for naming of resources in this deployment.')
param suffix string

var location = resourceGroup().location
var tags = {
  env: suffix
}
var uniqueKey = uniqueString(subscription().subscriptionId, suffix)

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'user-${uniqueKey}'
  location: location
  tags: tags
}

resource insights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'ai-${uniqueKey}'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 90
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource serverfarm 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'plan-${uniqueKey}'
  location: location
  tags: tags
  sku: {
    name: 'P2v2'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource site 'Microsoft.Web/sites@2022-03-01' = {
  name: 'app-${uniqueKey}'
  location: location
  tags: tags
  properties: {
    serverFarmId: serverfarm.id
    siteConfig: {
      appSettings: [
        { name: 'APPINSIGHTS_INSTRUMENTATIONKEY', value: insights.properties.InstrumentationKey }
      ]
      connectionStrings: [
        { 
          name: 'DefaultConnection'
          type: 'SQLAzure'
          connectionString: 'Server=tcp:server.${environment().suffixes.sqlServerHostname},1433;Initial Catalog=database;Persist Security Info=False;User ID=user;Password=password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'}
      ]
    }
  }
}


resource dbServer 'Microsoft.Sql/servers@2022-05-01-preview' ={
  name: 'sqlsrv-${uniqueKey}'
  location: location
  tags: tags
  properties: {
    administrators: {
      azureADOnlyAuthentication: true
      login: identity.name
      administratorType: 'ActiveDirectory'
      principalType: 'Application'
      sid: identity.properties.clientId
      tenantId: tenant().tenantId
    }
  }
}

resource database 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: dbServer
  name: 'sqldb-${uniqueKey}}'
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 10737418240
    licenseType: 'LicenseIncluded'
  }
}

