#!/usr/bin/env sh
set -e

# Get the parameters
brand=$(echo $1 | tr '[:upper:]' '[:lower:]')
user=$2
nodeindex=$3

# Set linux username
linux_username=$user-$nodeindex

# Get credentials from the YAML file
credentials_file="/home/$linux_username/.$brand-node.yaml"
username=$(grep 'username:' $credentials_file | awk '{print $2}' | tr -d "'")
password=$(grep 'password:' $credentials_file | awk '{print $2}' | tr -d "'")

# Create Service Name
servicename="$brand-node-$user-$nodeindex.service"

# Stop and delete the existing service
./script/delete-node.sh $brand $user $nodeindex

# Run the install script to upgrade the node
./script/install-$brand-v2-node.sh $brand $user $username $password $nodeindex
