#!/bin/bash

# Installer avhengigheter
sudo apt update
sudo apt install -y python3-venv expect

# Lag virtuell miljø for Flask
python3 -m venv /opt/connect/venv
source /opt/connect/venv/bin/activate

# Installer Python-avhengigheter i virtuell miljø
/opt/connect/venv/bin/pip install flask gunicorn python-dateutil dotenv

# Stopp tjenesten hvis den allerede finnes
servicename="connect-management"
if systemctl --all --type service | grep -q "$servicename"; then
    echo "Stopping Service $servicename"
    sudo systemctl stop "$servicename"
fi

# Opprett applikasjonsmappe
sudo mkdir -p /opt/connect
sudo cp -r ../* /opt/connect/

# Lag systemd-tjeneste med venv path
sudo tee /etc/systemd/system/$servicename.service > /dev/null <<EOT
[Unit]
Description=Connect United Node Management App
After=network.target

[Service]
User=root
WorkingDirectory=/opt/connect
ExecStart=/opt/connect/venv/bin/gunicorn \
            --timeout 10000 \
            --workers 3 \
            --bind 0.0.0.0:5000 service:app

[Install]
WantedBy=multi-user.target
EOT

# Start tjenesten
echo "Starting Service $servicename"
sudo systemctl daemon-reload
sudo systemctl start $servicename
sudo systemctl enable $servicename
sudo systemctl status $servicename

