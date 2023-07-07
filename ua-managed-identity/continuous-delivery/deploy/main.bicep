@description('The suffix to be used for naming of resources in this deployment.')
param suffix string
@description('The Mockaroo API key used to generate test data.')
param mockarooApiKey string 
@description('The Azure AD group name that will be used as an admin.')
param sqlAdminsGroupSecurityName string 
@description('The Azure AD group identifier that will be used as an admin.')
param sqlAdminsGroupSecurityIdentifier string 
@description('The location to deploy all resources in this deployment.')
param location string = resourceGroup().location
var tags = { env: suffix }
var uniqueKey = uniqueString(subscription().subscriptionId, suffix)

// User-Assigned Managed Identity
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'user-${uniqueKey}'
  location: location
  tags: tags
}

// Azure App Service Plan and Dependencies
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

// Azure App Service
var linuxFxVersion = 'dotnetcore|7.0'
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
      linuxFxVersion: linuxFxVersion
      logsDirectorySizeLimit: 100
      detailedErrorLoggingEnabled: true
      appSettings: [
        { name: 'APPINSIGHTS_INSTRUMENTATIONKEY', value: insights.properties.InstrumentationKey }
        { name: 'Mockaroo__ApiKey', value: mockarooApiKey }
      ]
      connectionStrings: [
        { 
          name: 'DefaultConnection'
          type: 'SQLAzure'
          connectionString: 'Server=tcp:${dbServer.name}${environment().suffixes.sqlServerHostname},1433;Database=${database.name};Authentication=Active Directory Managed Identity;Encrypt=True;User Id=${identity.properties.clientId};'
        }
      ]
    }
  }
}

// Source control deployment.
resource sourceControl 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
  name: 'web'
  parent: site
  properties: {
    repoUrl: 'https://github.com/overridethis/az-app-sql-mid.git'
    branch: 'main'
    isManualIntegration: true
  }
}

// Azure SQL Server
resource dbServer 'Microsoft.Sql/servers@2022-05-01-preview' ={
  name: 'sqlsrv-${uniqueKey}'
  location: location
  tags: tags
  properties: {
    administrators: {
      azureADOnlyAuthentication: true
      login: sqlAdminsGroupSecurityName
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      sid: sqlAdminsGroupSecurityIdentifier
      tenantId: tenant().tenantId
    }
  }
}

// Allow Azure Service and Resources to access this server
resource allowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  name: 'AllowAllWindowsAzureIps' // don't change the name
  parent: dbServer
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}
// Azure SQL Database.
resource database 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: dbServer
  name: 'sqldb-${uniqueKey}'
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 10737418240
    licenseType: 'LicenseIncluded'
  }
}
