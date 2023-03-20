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
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    serverFarmId: serverfarm.id
    siteConfig: {
      appSettings: [
        { name: 'APPINSIGHTS_INSTRUMENTATIONKEY', value: insights.properties.InstrumentationKey }
        { name: 'Db__RunMigrations', value: 'true' }
      ]
      connectionStrings: [
        { 
          name: 'DefaultConnection'
          type: 'SQLAzure'
          connectionString: 'Server=tcp:${serverfarm.name}.${environment().suffixes.sqlServerHostname},1433;Database=${database.name};Authentication=Active Directory Default;'}
      ]
    }
  }
}


resource sourceControl 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
  name: 'web'
  parent: site
  properties: {
    repoUrl: 'https://github.com/overridethis/az-app-sql-managed-identity.git'
    branch: 'main'
    isManualIntegration: false
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

output identityId string = identity.id
output identityClientId string = identity.properties.clientId
output identityPrincipalId string = identity.properties.principalId 
output identityTenantId string = identity.properties.tenantId
