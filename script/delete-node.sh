#!/usr/bin/env sh
set -e

#user=$(id -u -n)
#echo "Node (win, green, switch, element, galvan):"
brand=$1
#echo "Brukernavn:"
user=$2
#echo "Nodenummer"
nodeindex=$3

#Make sure brand name is in Lowercase
brand=$(echo "$brand" | tr '[:upper:]' '[:lower:]')

#Create Service Name
servicename="$brand-node-$user-$nodeindex.service"

#sleepdelay=5 #$((28+nodeindex*2))
username=$user-$nodeindex

#adduser $username --system

#Stop service, if already exist
echo "Trying remove service $servicename"
if systemctl --all --type service | grep -q "$servicename";then
    echo "Stopping Service $servicename"
    systemctl stop "$servicename"
    echo "Removing $brand-node-$username.service"
    systemctl disable "$servicename"    
    #echo "Deleting user: $username"
    #deluser --remove-home $username

    #Reload daemon
    systemctl daemon-reload
fi

#List service status
#systemctl list-units $brand-node-*.service