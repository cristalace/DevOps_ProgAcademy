sudo apt update && sudo apt upgrade -y
sudo apt install apache2 -y
sudo apt-get -y install maven -y


Create a directory for private key and certificate
#sudo mkdir /etc/apache2/ssl

Generate self-signed SSL certificate and private key
#sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt "UA IF Home Home1 Home2 test@mail.com"


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
sudo a2enmod ssl
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod rewrite
sudo a2enmod headers

sudo bash -c 'cat > /etc/default/jenkins << EOF
HTTP_HOST=127.0.0.1
JENKINS_ARGS="--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT --httpListenAddress=$HTTP_HOST"
EOF'
sudo systemctl restart apache2
sudo systemctl restart jenkins