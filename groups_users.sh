#!/bin/bash

group_names=$("Dev" "Ops" "Test")
user_names=$("devuser1" "opuser2" "testuser3")


# Creating groups
for group_name in "${group_names[@]}"
do
  if grep -q "^$group_name:" /etc/group; then
    echo "Group $group_name is already exist."
  else
    echo "Creating group $group_name..."
    groupadd "$group_name"
    echo "Group $group_name created."
  fi
done

# Creating users
for user_name in "${user_names[@]}"
do
  if id "$user_name" &>/dev/null; then
    echo "User <$user_name> is already exist."
  else
    echo "Creating user $user_name..."
    useradd -m -s /bin/bash 
	sudo useradd -m "$user_name"
	sudo passwd "$user_name"
    echo "$user_name:$password" | chpasswd
    echo "User <$user_name> created."
  fi
done

# Adding users to groups
for user_name in "${user_names[@]}"
do
  for group_name in "${group_names[@]}"
  do
    if groups "$user_name" | grep -q "\b$group_name\b"; then
      echo "User $user_name is in a $group_name."
    else
      echo "Adding user $user_name to gpoup $group_name..."
      usermod -aG "$group_name" "$user_name"
      echo "User $user_name succesfully added to $group_name."
    fi
  done
done
echo "Permissions for Dev"
sudo chown -W :Dev /var/www/html
echo "Permissions for Test"
sudo setfacl -R -m g:Test:rx /var/www/html
echo "Permissions for Ops"
sudo visudo add line %Ops ALL=(ALL:ALL) ALL

