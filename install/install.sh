#!/bin/bash

# Installer Flask og dens avhengigheter
sudo pip3 install flask gunicorn
sudo apt install expect

#Stop service, if already exist
servicename="connect-management"
if systemctl --all --type service | grep -q "$servicename";then
    echo "Stopping Service $servicename"
    systemctl stop "$servicename"    
fi

# Opprett mappen for Flask-applikasjonen
sudo mkdir -p /opt/connect

# Kopier Flask-applikasjonen til mappen
sudo cp -r ../* /opt/connect/

# Opprett en systemd-tjeneste for Flask-applikasjonen
sudo tee /etc/systemd/system/$servicename.service > /dev/null <<EOT
[Unit]
Description=Connect United Node Management App
After=network.target

[Service]
User=root
WorkingDirectory=/opt/connect
ExecStart=/usr/local/bin/gunicorn \
            --timeout 10000 \
            --workers 3 \
            --bind 0.0.0.0:5000 service:app

[Install]
WantedBy=multi-user.target
EOT

# Start tjenesten og aktiver den slik at den starter automatisk ved oppstart
echo "Starting Service $servicename"
sudo systemctl daemon-reload
sudo systemctl start $servicename
sudo systemctl enable $servicename
sudo systemctl status $servicename
