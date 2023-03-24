# Accessing Azure SQL Server with a User-Assigned Managed Identity
It is easier to design and mantain a secure system than to add security after the fact.  When it comes to the Microsoft Cloud there are plenty of tools and guides on building a secure architecture for your clouds solution, some are listed in the [references](#references) section of this post. Now automating those best practices into your SDLC is the real challenge.

In this post we will enforce the "**Minimize the use of password-based authentication for users**" in a simple web application hosted in an Azure App Service that relies on an Azure SQL Database using a user-assigned Managed Identity.

## Architecture



## Reference
1. [Playbook for addressing common security requirements with Azure SQL Database and Azure SQL Managed Instance](https://learn.microsoft.com/en-us/azure/azure-sql/database/security-best-practice?view=azuresql)
2. [An overview of Azure SQL Database and SQL Managed Instance security capabilities](https://learn.microsoft.com/en-us/azure/azure-sql/database/security-overview?view=azuresql)
3. [Microsoft Operational Security Practices - Practice #4 - Protect Secrets](https://www.microsoft.com/en-us/securityengineering/osa/practices#practice4)