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
## Service connection setup:
--------
1. Navigate to portal
2. Navigate to Microsoft EntraID > App registrations > New app registration > Give a name eg: lucky
3. Navigate to lucky > top right secret > create a secret Now note down
```bash
Application (client) ID: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Object ID :xxxxxxxxxxxxxxxxxxxxxxxx
Directory (tenant) ID :xxxxxxxxxxxxxxxxxxxx
value : xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Secret ID: Xxxxxxxxxxxxxxxxxxxxxxxxx
subscription ID: Xxxxxxxxxxxxxxxxxxxxxxxx
```

3. Assigning Role to lucky
- Navigate to the Subscriptions in portal
- Open the IAM (Access Control) Blade
    - In the subscription panel, select "Access control (IAM)"
- Click on the "Role assignments" tab
- Add Role Assignment
  - Click the "+ Add" button
  - Select "Add role assignment" from the dropdown
- Configure Role Assignment
  - Role: In the Role tab, search and select "Owner"
  - Click "Next"
- Assign Access to User
  - In the Members tab:
  - Scope: Leave as default (User, group, or service principal)
  - Click "+ Select members"
  - Type lucky in the search bar
  - Select the matching user account
  - Click "Select"
•	Click "Next"
- Set Conditions
  - In the Conditions (preview) tab:
  - Choose the recommended condition shown (typically for least privilege or conditional access context)
  - Review what the condition does
  - Click "Next"
- Review and Assign
  - Review all your selections
  - Click "Review + assign"
  - Confirm the assignment once more if prompted

- create an Azurerm service connection Project settings-->service connections--> New service Connection--> Azure Resource Manager
  - Identity Type: App registration or managed identity(manual)
  - credential: secret
  - Environment: Azure cloud
  - scope level: subscription
  - subscription ID: you-subscription-ID
  - subscription name: your subscription name
  - application(client ID): your applicationclientID
  - Directory(tenant)ID: your directory TenantID
  - credential-->service principal key
  - client secret : password
  - service connection Name: luckyconnect1234       #you can give any name that is upto you
------

7. Configure URL in App Service
- Go to App Service → Settings → Environment Variables-->App settings
	- Click add
	- Name: baseUrls__webBase
	- Value: https://dotwebapp123456-bkgkdvhgdwg4e0b0.canadacentral-01.azurewebsites.net/ 
- Value here should be your app service URL not above

- Navigate to your Azure DevOps and the project-->Repos
- src/web/Appsettings.json on the top rigt edit 
- Change
  ```bash
    "apiBase": "https://localhost:5099/api/",
    "webBase": https://localhost:44315/
  ```
 to
 ```
 "apiBase": "https://dotwebapp123456-bkgkdvhgdwg4e0b0.canadacentral-01.azurewebsites.net/api/",
 "webBase": https://dotwebapp123456-bkgkdvhgdwg4e0b0.canadacentral-01.azurewebsites.net/
```
- Change connection strings section 
```bash
"CatalogConnection": "Server=(localdb)\\mssqllocaldb;Integrated Security=true;Initial Catalog=Microsoft.eShopOnWeb.CatalogDb;",
"IdentityConnection": "Server=(localdb)\\mssqllocaldb;Integrated Security=true;Initial Catalog=Microsoft.eShopOnWeb.Identity;"
```
to
```bash 
"CatalogConnection": "Server=tcp:eshop-sql-server-1234.database.windows.net,1433;Initial Catalog=eshop-db;Persist Security Info=False;User ID=sqladmin;Password=YOUR_NEW_PASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;",
"IdentityConnection": "Server=tcp:eshop-sql-server-1234.database.windows.net,1433;Initial Catalog=eshop-db;Persist Security Info=False;User ID=sqladmin;Password=YOUR_NEW_PASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
```

- Finally Commit. Here I have placed my dotnet webapp url but you should use yours. Mostly connections are same if you use the same creds which I mentioned above if it changs you need to change



- Same in the program . cs chage the below section to 
```bash
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
```

To 

```bash
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
```
- Finally commit
- Now navigate to Pipelines new pipeline select your repo starter pipeline and then start writing stages for below
- Build
	- Install dotnet 8 sdk
	- Dotnet restore
	- Dotnet build
	- Dotnet test
	- Publish the build file
	- Zip the published output
	- Store the zip in drop as artifact
- DEPLOY TO DEV
	- Download current artifact
	- Deploy to Azure app service
- DEPLOY TO PROD
	- Download current artifact
	- Deploy to Azure app service

### Testings:
----
- Browse the Azure app service URL you will get the web page like Below
<img width="1880" height="944" alt="image" src="https://github.com/user-attachments/assets/0ddf3566-4bbc-4823-b509-91f223f64f66" />

- On the Top right of website click login and provide the creds which are default given at the bottom the website page
- select any item and Add to basket then checkout then pay now. so your order will be placed.
## Database test:
- navigate to your Database in the Azure portal--> search for Query editor and login with creds in the query type this ```bash select *FROM [dbo].[Orders] ```
<img width="1796" height="768" alt="image" src="https://github.com/user-attachments/assets/c96f4f9d-66f7-4848-855d-46ff035a6ec0" />
