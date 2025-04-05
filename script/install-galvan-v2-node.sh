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

# Add system user and home directory
adduser --system --home /home/$username --disabled-password --shell /bin/false $username
mkdir -p /home/$username
chown $username /home/$username

#Stop service, if already exist
if systemctl --all --type service | grep -q "$servicename";then
    echo "Stopping Service $servicename"
    systemctl stop "$servicename"    
fi

echo "Installing $brand-node-$username.service (wait $((sleepdelay))s ..)"

#Create config expect file
expectfile="/home/$username/.$brand-node.exp"
cat >"$expectfile" <<EOL
#!/usr/bin/expect
spawn /usr/local/bin/$brand-node-$username config
expect "Galvan Username:"
send "$email\r"
expect "Galvan Password:"
send "$password\r"
expect eof
EOL
chown $username /home/$username/.$brand-node.exp
chmod +x "$expectfile"

#Download locations
date=$(date +%s)
domain="download.galvan.health"
download_url="https://$domain/node-binaries/v2.6.1-b/$brand-v2.6.1-b_linux-amd64?$date"
node="/usr/local/bin/$brand-node-$username"

#Remove old software
rm -f $node
#Download node software
wget --continue "$download_url" --output-document "$node" --quiet
chmod +x "$node"

#Configure and remove input file after use.
sudo -u $username $expectfile
rm $expectfile

#Create service
cat >"/etc/systemd/system/$brand-node-$username.service" <<EOL
[Unit]
Description=$brand node
After=network.target
StartLimitIntervalSec=0
[Service]
User=$username
ExecStart=$node
StartLimitInterval=0
Restart=always
RestartSec=30
Environment="NODE_LOG_LEVEL=info"
[Install]
WantedBy=multi-user.target
EOL

#Start node
systemctl daemon-reload
systemctl start "$servicename"
systemctl enable "$servicename"

#List service status
#systemctl list-units $brand-node-*.service