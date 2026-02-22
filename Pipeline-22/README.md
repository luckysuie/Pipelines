
## DOTNET eShopOnWeb Deployment to Azure App Service using Azure DevOps pipeline and Azure SQL
Steps:
1. Fork the Repository
- Go to: https://github.com/dotnet-architecture/eShopOnWeb
- Click Fork
- Create the fork under your GitHub account
________________________________________
2. Create Azure DevOps Project
- Login to Azure DevOps
- Click New Project
- Give project name (example: DotnetEshop)
- Select Visibility (Private/Public)
- Click Create
________________________________________
3. Import Forked Repository into Azure DevOps
- Go to Repos
- Click Import Repository
- Paste your forked GitHub repository URL
- Import the repository into Azure DevOps
________________________________________
4. Create Azure SQL Database
- Create Azure SQL Database with the following details:
  - SQL Server
    - Server name: eshop-sql-server-1234
    - Authentication: SQL Authentication
    - Username: eshopadmin
    - Password: (your configured password)
- Database
  - Database Name: eshop-db
- Networking
  - Network connectivity: Public endpoint
  - Allow Azure services and resources to access this server: Yes
  - Add current client IP address: Yes
  - Click Review + Create
________________________________________
5. Create Azure App Service
- Go to Azure Portal
- search App serviece
- Select Web App
  - App name: dotwebapp123456
  - Runtime stack: .NET 8
  - Operating System: Windows
  - Region: (same region as SQL if possible)
  - App Service Plan: Create new or use existing
  - Click Review + Create
________________________________________
6. Configure Connection Strings in App Service
- Go to App Service → Settings → Environment Variables--> Connection Strings
  - Add: CatalogConnection
  - Type: SQLAzure
  - Value: (Azure SQL connection string)
- Click add
  - Add: IdentityConnection
  - Type: SQLAzure
  - Value: same Connection string
- Click Save and restart the app serve

Connection String Example: Server=tcp:eshop-sql-server-1234.database.windows.net,1433;Initial Catalog=eshop-db;Persist Security Info=False;User ID=eshopadmin;Password={your_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
This should be your REAL PASSWORD
________________________________________
7. Configure URL in App Service
•	Go to App Service → Settings → Environment VariablesApp settings
Click add
Name: baseUrls__webBase
Value: https://dotwebapp123456-bkgkdvhgdwg4e0b0.canadacentral-01.azurewebsites.net/ 
Value here should be your app service URL not above

Navigate to your Azure DevOps and the project Repos
Web Appsettings.json on the top rigt edit 
Change base
    "apiBase": "https://localhost:5099/api/",
    "webBase": https://localhost:44315/
 to
 "apiBase": "https://dotwebapp123456-bkgkdvhgdwg4e0b0.canadacentral-01.azurewebsites.net/api/",
    "webBase": https://dotwebapp123456-bkgkdvhgdwg4e0b0.canadacentral-01.azurewebsites.net/

Change connection strings section to 
"CatalogConnection": "Server=(localdb)\\mssqllocaldb;Integrated Security=true;Initial Catalog=Microsoft.eShopOnWeb.CatalogDb;",
    "IdentityConnection": "Server=(localdb)\\mssqllocaldb;Integrated Security=true;Initial Catalog=Microsoft.eShopOnWeb.Identity;"

 "ConnectionStrings": {
    "CatalogConnection": "Server=tcp:eshop-sql-server-1234.database.windows.net,1433;Initial Catalog=eshop-db;Persist Security Info=False;User ID=sqladmin;Password=YOUR_NEW_PASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;",
    "IdentityConnection": "Server=tcp:eshop-sql-server-1234.database.windows.net,1433;Initial Catalog=eshop-db;Persist Security Info=False;User ID=sqladmin;Password=YOUR_NEW_PASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  },

Finally Commit
Here I have placed my dotnet webapp url but you should use yours. Mostly connections are same if you use the same creds which I mentioned above if it changs you need to change



Same in the program . cs chage the below section to 
else{
    // Configure SQL Server (prod)
    var credential = new ChainedTokenCredential(new AzureDeveloperCliCredential(), new DefaultAzureCredential());
    builder.Configuration.AddAzureKeyVault(new Uri(builder.Configuration["AZURE_KEY_VAULT_ENDPOINT"] ?? ""), credential);
    builder.Services.AddDbContext<CatalogContext>(c =>
    {
        var connectionString = builder.Configuration[builder.Configuration["AZURE_SQL_CATALOG_CONNECTION_STRING_KEY"] ?? ""];
        c.UseSqlServer(connectionString, sqlOptions => sqlOptions.EnableRetryOnFailure());
    });
    builder.Services.AddDbContext<AppIdentityDbContext>(options =>
    {
        var connectionString = builder.Configuration[builder.Configuration["AZURE_SQL_IDENTITY_CONNECTION_STRING_KEY"] ?? ""];
        options.UseSqlServer(connectionString, sqlOptions => sqlOptions.EnableRetryOnFailure());
    });
}


To 


{
    // NO Key Vault - read directly from ConnectionStrings
    builder.Services.AddDbContext<CatalogContext>(c =>
    {
        var cs = builder.Configuration.GetConnectionString("CatalogConnection");
        c.UseSqlServer(cs, sqlOptions => sqlOptions.EnableRetryOnFailure());
    });

    builder.Services.AddDbContext<AppIdentityDbContext>(options =>
    {
        var cs = builder.Configuration.GetConnectionString("IdentityConnection");
        options.UseSqlServer(cs, sqlaOptions => sqlOptions.EnableRetryOnFailure());
    });
}

Finally commit

Now navigate to Pipelines new pipeline select your repo starter pipeline and then start writing stages for below
Build
	Install dotnet 8 sdk
	Dotnet restore
	Dotnet build
	Dotnet test
	Publish the build file
	Zip the published output
	Store the zip in drop as artifact
DEPLOY TO DEV
	Download current artifact
	Deploy to Azure app service
DEPLOY TO PROD
	Download current artifact
	Deploy to Azure app service

