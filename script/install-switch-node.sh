#!/usr/bin/env sh
set -e

#user=$(id -u -n)
#echo "Node (win, green, switch, element, galvan):"
brand=$1
#echo "Brukernavn:"
user=$2
#echo "E-post"
email=$3
#echo "Passord"
password=$4
#echo "Nodenummer"
nodeindex=$5

#Create Service Name
servicename="$brand-node-$user-$nodeindex.service"

sleepdelay=$((27+nodeindex*3))
username=$user-$nodeindex

adduser $username --system

#Stop service, if already exist
if systemctl --all --type service | grep -q "$servicename";then
    echo "Stopping Service $servicename"
    systemctl stop "$servicename"    
fi

echo "Installing $brand-node-$username.service (wait $((sleepdelay))s ..)"

#Create node credential file
cat >"/home/$username/.$brand-node.yaml" <<EOL
username: '$email'
password: '$password'
nodename: '$brand-node-$nodeindex'
EOL
chown $username /home/$username/.$brand-node.yaml

#Download locations
domain="static.connectblockchain.net"
download_url="https://$domain/softnode/$brand-node_linux-amd64"
node="/usr/local/bin/$brand-node-$username"

#Remove old software
rm -f $node

#Download node software
wget --continue "$download_url" --output-document "$node" --quiet
chmod +x "$node"
#$node config

#Create service
cat >"/etc/systemd/system/$brand-node-$username.service" <<EOL
[Unit]
Description=$brand node
After=network.target
[Service]
User=$username
ExecStart=$node
ExecStartPre=/bin/sleep $sleepdelay
Restart=always
[Install]
WantedBy=multi-user.target
EOL

#Start node
systemctl daemon-reload
systemctl start "$servicename"
systemctl enable "$servicename"

#List service status
#systemctl list-units $brand-node-*.service