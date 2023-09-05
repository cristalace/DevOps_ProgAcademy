#!/bin/bash

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




#Install jenkins
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y

#Change HTTP_HOST
sudo bash -c 'cat > /etc/default/jenkins << EOF
HTTP_HOST=127.0.0.1
JENKINS_ARGS="--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT --httpListenAddress=$HTTP_HOST"
EOF'

sudo systemctl stop jenkins

sudo apt install python3-pip -y
sudo pip3 install awscli 

sudo rm -rf var/lib/jenkins/

#Copying Jenkins from s3 bucket
sudo aws s3 cp s3://progacad.devops/jenkinsConfigureFiles/jenkins-backup.tar.gz jenkins-backup.tar.gz
sudo tar -zxvf jenkins-backup.tar.gz -C /


sudo ufw allow OpenSSH
#enabling firewall
sudo ufw enable -y
sudo apt update -y
sudo apt install apache2 -y
#List the ufw application profiles
sudo ufw app list
#Allowing Appache
sudo ufw allow 'Apache'
#Status of firewall and list of allowed HTTP traffic
sudo ufw status
#Making sure the service is runnig correctly
sudo systemctl status apache2

#Setup ssl
sudo mkdir /etc/apache2/ssl

#Generate self signed ssl certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt

#Setup Apache
sudo bash -c 'cat > /etc/apache2/sites-available/000-default.conf << EOF
<VirtualHost *:80>
   ServerName localhost
   Redirect / https://localhost/
</VirtualHost>

<VirtualHost *:443>
   SSLEngine on
   SSLCertificateFile /etc/apache2/ssl/apache.crt
   SSLCertificateKeyFile /etc/apache2/ssl/apache.key

   ProxyRequests Off
   ProxyPreserveHost On
   ProxyPass / http://localhost:8080/
   ProxyPassReverse / http://localhost:8080/
</VirtualHost>
EOF'

#Setup proxy
sudo bash -c 'cat > /etc/apache2/mods-enabled/proxy.conf << EOF
<IfModule mod_proxy.c>
ProxyPass         /  http://localhost:8080/ nocanon
ProxyPassReverse  /  http://localhost:8080/
ProxyRequests     Off
AllowEncodedSlashes NoDecode

<Proxy http://localhost:8080/*>
  Order deny,allow
  Allow from all
</Proxy>
</IfModule>
EOF'

#Install Apache mods
sudo a2enmod ssl     
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod rewrite
sudo a2enmod headers


#Restart both services
sudo systemctl restart apache2
sudo systemctl start jenkins