## PIPELINE-17: CI/CD PIPELINE DEPLOYMENT ON AZURE DEVOPS WITH SELF-HOSTED LINUX AGENT FOR JAVA APPLICATION
1.	Create a Azure Devops project in your Azure Devops portal
2.	Import the repo as shown below
- Repo: https://github.com/rajcocvs/git_practise4 

 
<img width="1906" height="955" alt="Screenshot 2025-11-10 151115" src="https://github.com/user-attachments/assets/dfcc8e5e-b665-49b7-9625-fc718d406384" />

- Keep it like that for some time

3.	Generate a PAT token for your Azure Devops Token which we will use later
4.	Navigate to organization settings>Agent Pools>Default on the top right New agent
5.	Navigate to Linux and which on displayed screen and click on copy which copies your agent url. Note it down in notepad
6.	Navigate to Azure cloud portal and create an ubuntu VM with all ports open or only 8080 port
7.	Login to VM using putty or teminal and perform the below
```bash
sudo apt update
mkdir myagent
cd myagent/
wget https://download.agent.dev.azure.com/agent/4.264.2/vsts-agent-linux-x64-4.264.2.tar.gz   #here you need to place your agent URL not this
tar -xvzf vsts-agent-linux-x64-4.264.2.tar.gz
ls
./config.sh
```

- Enter (Y/N) Accept the Team Explorer Everywhere license agreement now? (press enter for N) > Just click enter
- Enter server URL > https://dev.azure.com/luckyashu1856    # Enter your URL here
- Enter authentication type (press enter for PAT) > just click enter
- Enter personal access token > Give your Azure Devops PAT Token
```bash
ls
./run.sh
```
- Now you can see your agent online in the Azure DevOps portal

## Running Agent as a service:
1.	Before running agent as service first stop just type ctrl+c
2.	Why Run the Agent as a Service?
    - It automatically starts when your Ubuntu VM restarts — no manual ./run.sh needed.
    - It runs continuously in the background, ideal for build/deployment pipelines.
    - In short:
        - Manual run = temporary session.
      - Service run = reliable background process (production-ready).

- Inside mygent folder of the VM perform below(Execute one after another)
```bash
  sudo ./svc.sh install
  sudo ./svc.sh start
  sudo ./svc.sh status
```
- Now pipeline process starts
1.	Install below in the agent(which is called our VM)
2.	Install maven
```bash
sudo apt update
sudo apt install openjdk-17-jdk -y
sudo apt install maven -y
```
4.	Install and set user for tomcat
```bash
sudo apt update
Wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.111/bin/apache-tomcat-9.0.111.tar.gz 
tar -xvzf apache-tomcat-9.0.111.tar.gz
ls
mv apache-tomcat-9.0.111.tar.gz  tomcat
```
```bash
 vi ~/tomcat/webapps/manager/META-INF/context.xml
```
- you need to remove the Below part and save and exit
```bash
  <Valve className="org.apache.catalina.valves.RemoteCIDRValve"
         allow="127.0.0.0/8,::1/128" />
 ```
 ```bash
 vi ~/tomcat/conf/tomcat-users.xml
```
```bash	
  paste the Below in users section and save and exit
<role rolename="manager-gui"/>
<role rolename="manager-script"/>
<role rolename="manager-status"/>
<role rolename="admin-gui"/>
<user username="admin" password="admin123" roles="manager-gui,manager-script,manager-status,admin-gui"/>
```
- Verification: Browse the public ip with 8080it should show Tomcat page and click on sever status give username and password it will navigate you to that page.

### Pipeline:
1.	Enable classic editor organization settings>pipelines>settings>Disable creation of classic release pipelines and Disable creation of classic build pipelines. By on and off check whether its enabled or not
2.	Navigate to pipelines>New pipeline>classic editor
3.	Select a source : Azure Repos Git
4.	check project name and your repository>continue>top right search for Maven and click apply
### This is CI part
- In the pipeline section and in the Agent Job section the Agent pool must be Default
    - Reason: our Agent is in Default pool
    - In this Copy Files to: $(build.artifactstagingdirectory) section 
    - Contents:  change **/*.jar----- > **/*.war
- Reason: This repo produces war file not jar
- Leave everything as it is and save and run it should run succesfully without any errors.

### CD part
1.	click on the +icon which is shown in Agent set which you created then you will be navigated to add tasks
2.	search for Tomcat and click on Add

- Tomcat section:
	  - Display name: Deploy application to a Tomcat server
    - Tomcat Server URL: http://13.90.134.131:8080 
    - Tomcat Manager Username: admin
    - Password: admin123
    - WAR File: /home/LakshmiNarayana/myagent/_work/1/s/target/webappExample.war 
- Note: In place of LakshmiNarayana it should be your VM username

- Pipeline output:
 
<img width="1834" height="903" alt="Screenshot 2025-11-10 175350" src="https://github.com/user-attachments/assets/f5709d6e-60df-4f55-9d3d-0ad412374f77" />


- Web page: 
  - http://13.90.134.131:8080/webappExample/  # in place of Ipaddress here it should be yours

 <img width="1919" height="751" alt="Screenshot 2025-11-10 175337" src="https://github.com/user-attachments/assets/a3c259d0-6f5a-49f9-9fc6-025b0902ce54" />




THE END
