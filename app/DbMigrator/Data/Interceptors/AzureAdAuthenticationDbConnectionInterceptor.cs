using System.Data.Common;
using Azure.Core;
using Azure.Identity;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Extensions.Options;

using DbMigrator.Tasks;
using DbMigrator.Tasks.Migrator;

namespace DbMigrator.Data.Interceptors;

public class AzureAdAuthenticationDbConnectionInterceptor : DbConnectionInterceptor
{
    
    // See https://docs.microsoft.com/azure/active-directory/managed-identities-azure-resources/services-support-managed-identities#azure-sql
    private static readonly string[] AzureSqlScopes = { "https://database.windows.net//.default" };
    private static readonly TokenCredential Credential = new ChainedTokenCredential(
        new ManagedIdentityCredential(),
        new EnvironmentCredential());
    
    private readonly IOptions<MigratorConfiguration> _configuration;

    public AzureAdAuthenticationDbConnectionInterceptor(IOptions<MigratorConfiguration> configuration)
    {
        _configuration = configuration;
    }

    public override InterceptionResult ConnectionOpening(
        DbConnection connection,
        ConnectionEventData eventData,
        InterceptionResult result)
    {
        var sqlConnection = (SqlConnection)connection;
        
        if (DoesConnectionNeedAccessToken(sqlConnection))
        {
            var tokenRequestContext = new TokenRequestContext(AzureSqlScopes);
            var token = Credential.GetToken(tokenRequestContext, default);

            sqlConnection.AccessToken = token.Token;
        }

        return base.ConnectionOpening(connection, eventData, result);
    }

    public override async ValueTask<InterceptionResult> ConnectionOpeningAsync(
        DbConnection connection,
        ConnectionEventData eventData,
        InterceptionResult result,
        CancellationToken cancellationToken = default)
    {
        var conn = (SqlConnection)connection;
        if (_configuration.Value.Mode == RunMode.AccessToken)
        {
            if (DoesConnectionNeedAccessToken(conn))
            {
                var tokenRequestContext = new TokenRequestContext(AzureSqlScopes);
                var token = await Credential.GetTokenAsync(tokenRequestContext, cancellationToken);
                conn.AccessToken = token.Token;
            }    
        }
        return await base.ConnectionOpeningAsync(connection, eventData, result, cancellationToken);
    }

    private static bool DoesConnectionNeedAccessToken(SqlConnection connection)
    {
        // Only try to get a token from AAD if
        //  - We connect to an Azure SQL instance; and
        //  - The connection doesn't specify a username.
        var builder = new SqlConnectionStringBuilder(connection.ConnectionString);
        return builder.DataSource.Contains("database.windows.net", StringComparison.OrdinalIgnoreCase)
            && string.IsNullOrEmpty(builder.UserID);
    }
}