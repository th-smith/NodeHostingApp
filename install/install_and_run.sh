#!/bin/bash

# Oppdater systemet og installer nødvendige pakker
sudo apt-get update
sudo apt-get install -y git python3-pip curl unzip

# Hent den nyeste utgivelsen fra GitHub
#LATEST_RELEASE="https://github.com/th-smith/NodeHostingApp/archive/refs/tags/latest.tar.gz"

# Last ned og pakk ut den nyeste utgivelsen
#curl -LJO $LATEST_RELEASE
echo $(curl -s https://api.github.com/repos/th-smith/NodeHostingApp/releases/latest | grep "browser_download_url.*tar.gz" | cut -d : -f 2,3 | tr -d \")
#rm -r latest_release
#mkdir latest_release
#tar -xzf latest_release.tar.gz --strip-components=1 -C latest_release
#cd latest_release
#rm -f ../latest_release.tar.gz
# 
# # Opprett et virtuelt miljø og installer avhengigheter
# python3 -m venv venv
# source venv/bin/activate
# pip install -r requirements.txt
# 
# # Kjør Flask-appen
# export FLASK_APP=app.py
# flask run
