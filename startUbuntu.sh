#!/bin/bash
KEY_NAME=TestEnv_key

chmod 400 $KEY_NAME.pem
echo "connection attempt via ssh"
ssh -i "$KEY_NAME.pem" ubuntu@ec2-16-171-135-64.eu-north-1.compute.amazonaws.com -y
echo "allowing OpenSSH"
sudo ufw allow OpenSSH
echo "enabling firewall"
sudo ufw enable -y
sudo apt update -y
sudo apt install apache2
echo "List the ufw application profiles"
sudo ufw app list
echo "Allowing Appache"
sudo ufw allow 'Apache'
echo "Status of firewall and list of allowed HTTP traffic "
sudo ufw status
echo "Making sure the service is runnig correctly"
sudo systemctl status apache2
