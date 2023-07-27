#!/bin/bash

# Function to install Apache2 on Debian/Ubuntu
install_apache2_debian() {
    echo "Detected Debian/Ubuntu. Installing Apache2..."
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
}

# Function to install Apache2 on RHEL/CentOS
install_apache2_centos() {
    echo "Detected CentOS/RHEL. Installing Apache2..."
    sudo yum clean all
sudo yum -y update
sudo yum -y install httpd
sudo yum -y install firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-service=http --add-service=https
sudo firewall-cmd --reload
sudo systemctl start httpd
sudo systemctl enable httpdcat /etc/os-releasecd
sudo systemctl status httpd
}

# Main script
kernel_name=$(uname -s)

case $kernel_name in
    Linux )
        # Check if it's Debian/Ubuntu or CentOS/RHEL
        if [ -f /etc/debian_version ]; then
            install_apache2_debian
        elif [ -f /etc/redhat-release ] || [ -f /etc/centos-release ]; then
            install_apache2_centos
        else
            echo "Unsupported Linux distribution."
            exit 1
        fi
        ;;
    * )
        echo "Unsupported operating system: $kernel_name"
        exit 1
        ;;
esac

echo "Apache2 installation completed successfully!"
