1 Create 2 EC2 instances (ubuntu). Jenkins_Master, Jenkins_Slave
	? add custom security group (Select existing security group) with 
	
2 Connenct via SSH to Jenkins_Master and install Jenkins

#Upgrade
sudo apt update && sudo apt upgrade -y

#Install Java
sudo apt install openjdk-11-jdk -y

#Add key for Jenkins package
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null

#Add repository for installation
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null

#Upgrade
sudo apt-get update

#Install jenkins
sudo apt-get install jenkins -y

#Change HTTP_HOST
sudo bash -c 'cat > /etc/default/jenkins << EOF
HTTP_HOST=127.0.0.1
JENKINS_ARGS="--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT --httpListenAddress=$HTTP_HOST"
EOF'

#Restart service
sudo systemctl restart jenkins

3 Connenct via SSH to Jenkins_Slave and install java
#Upgrade
sudo apt update && sudo apt upgrade -y

#Install Java
sudo apt install default-jre

Login to Jenkins_Master using <Public IPv4 address>:8080 in your browser
	add new node jenkins_Slave 
	
4 Create new job "Install Appache+SSL+Maven" (freestyle project) on your Jenkins_Master
	- "Restrict where this project can be run" - right down "slave"
	- in build steps choose "execute shell" and copy from 'Install Appache+SSL+Maven'
	
4 Create new job "Install WildFly" (freestyle project) on your Jenkins_Master
	- "Restrict where this project can be run" - right down "slave"
	- in build steps choose "execute shell" and copy from 'Install WildFly'
	
6 Create new job "Simple_build" (freestyle project) on your Jenkins_Master
	- "Restrict where this project can be run" - right down "slave"
	- Source Code Management - git 
		Repository URL - https://github.com/YegorMaksymchuk/WildFly-Servlet-Example.git 
		Credentials - ubuntu
		Branch Specifier (blank for 'any') - */main
	- Build Environment - "checkbox" Delete workspace before build starts
	- Build Steps - "Execute shell", right down "mvn install"
	
7 Create new job "Simle_deploy" (freestyle project) on your Jenkins_Master
	- "Restrict where this project can be run" - right down "slave"
	- "Build Triggers" - "Build after other projects are built" - right down "Simple_build"
	-  Build Steps - "Execute shell", right down 
	"cd $HOME/workspace/Simple_Build/target
	 pwd
	 ls -ltrha
	 sudo mv devops-1.0-SNAPSHOT.war /opt/wildfly/standalone/deployments"
	 
8 Startup sequence 
	- Install Appache+SSL+Maven
	- Install WildFly
	- Simple_build
	
9