Bootcamp-1: Java Spring Boot Deployment Pipeline with Jenkins, Argo CD & AKS
Process:
-----------
1.	Create a ubuntu VM with 4vCpus and 16GiB memoy with all ports open
2.	Login to VM using SSH and do the below
a.	Install Git
b.	Jenkins installation and verification
c.	Docker Installation and rootless access setup then restart jenkins and docker after this(without fail)
d.	Sonarqube as a Docker Container
e.	Install AZ and Login to your Account
f.	Install Kubectl
g.	Install prometheus and grafana










On your Ubuntu VM:

nano devops-stack-setup.sh


Paste the entire script, save (Ctrl+O, Enter, Ctrl+X).

Make it executable:

chmod +x devops-stack-setup.sh


Run it:

./devops-stack-setup.sh
