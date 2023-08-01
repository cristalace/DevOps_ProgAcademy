#!/bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt install openjdk-11-jdk -y
sudo apt install apache2 -y

wget https://download.jboss.org/wildfly/24.0.1.Final/wildfly-24.0.1.Final.tar.gz
tar xf wildfly-24.0.1.Final.tar.gz
sudo mv wildfly-24.0.1.Final /opt/wildflycd 

sudo useradd --system --no-create-home --user-group wildfly
sudo chown -R wildfly:wildfly /opt/wildfly

sudo bash -c 'cat > /etc/systemd/system/wildfly.service << EOF
[Unit]
Description=The WildFly Application Server
After=syslog.target network.target

[Service]
User=wildfly
Group=wildfly
ExecStart=/opt/wildfly/bin/standalone.sh -b=0.0.0.0
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload

sudo systemctl enable wildfly

sudo mkdir /etc/apache2/ssl
#необходимо добавить параметры ( страна, область, имя организации, юнит организации, common name, email) 
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt "UA IF Home Home1 Home2 test@mail.com"

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

sudo a2enmod ssl
sudo a2enmod proxy
sudo a2enmod proxy_http

sudo systemctl restart apache2

sudo sed -i 's/<inet-address value="${jboss.bind.address.management:127.0.0.1}"/<inet-address value="${jboss.bind.address.management:0.0.0.0}"/g' /opt/wildfly/standalone/configuration/standalone.xml
sudo sed -i 's/<inet-address value="${jboss.bind.address:127.0.0.1}"/<inet-address value="${jboss.bind.address:0.0.0.0}"/g' /opt/wildfly/standalone/configuration/standalone.xml

sudo systemctl restart wildfly

sudo mkdir /etc/wildfly
sudo bash -c 'cat > /etc/wildfly/wildfly.conf << EOF
# The configuration you want to run
WILDFLY_CONFIG=standalone.xml

# The mode you want to run
WILDFLY_MODE=standalone

# The address to bind to
WILDFLY_BIND=0.0.0.0
EOF'

sudo bash -c 'cat > /opt/wildfly/bin/launch.sh<< EOF
#!/bin/sh
if [ "$1" = "domain" ]; then
    /opt/wildfly/bin/domain.sh -c $2 -b $3
else
    /opt/wildfly/bin/standalone.sh -c $2 -b $3
fi

EOF'
sudo chmod +x /opt/wildfly/bin/launch.sh
