# Copyright (C) 2023 Tommy H. Smith
from flask import Flask, render_template, request, redirect, flash, Response
from dateutil.parser import parse
import subprocess
import re
import datetime
import os

# Load environment variables from .env file
from dotenv import load_dotenv
load_dotenv()

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY') or 'default-secret-key'

def is_valid_date(date):
    if date:
        try:
            parse(date)
            return True
        except:
            return False
    return False

def get_services():
    output = subprocess.check_output(["systemctl", "list-units", "--type=service", "--all"])
    services = output.decode().strip().split("\n")
    return services

def get_version(service_name):
    base_service_name = os.path.basename(service_name)
    binary_name = base_service_name.split('.service')[0]
    try:
        version_output = subprocess.check_output([f"/usr/local/bin/{binary_name}", "version"])
        version_output = version_output.decode()

        # Use regular expressions to extract version information
        version_match = re.search(r'v[0-9a-zA-Z.-]+', version_output)
        if version_match:
            version_info = version_match.group(0)
        else:
            version_info = "Version not available"
        
    except subprocess.CalledProcessError as e:
        # Handle the case where the version command fails for a service
        version_info = "Version not available"
    
    return version_info

def get_service_uptime(service_name):
    output = subprocess.check_output(["systemctl", "show", service_name, "--property=ExecMainStartTimestamp"])
    start_timestamp = output.decode().strip().split("=")[1].split(".")[0]
    start_time = datetime.datetime.now()
    if is_valid_date(start_timestamp):
        start_time = datetime.datetime.strptime(start_timestamp, "%a %Y-%m-%d %H:%M:%S %Z")
    uptime = datetime.datetime.now() - start_time
    return str(uptime)

def get_service_log(service_name):
    output = subprocess.check_output(["journalctl", "-u", service_name])
    log = output.decode().strip().split("\n")[-1]
    return log

@app.route("/")
def index():
    services = get_services()
    filtered_services = []
    row = 0
    for service in services:
        service_info = service.split()
        if len(service_info) < 2:
            continue
        service_name = service_info[0]
        if "-node-" not in service_name:
            continue
        row = row + 1
        loaded = service_info[1]
        active = "Running" if "running" in service else "Stopped"
        name = service_name.split("-node-")[1].split(".service")[0].split("-")[0]
        node = service_name.split("-node-")[0].title()
        index = int(service_name.split("-node-")[1].split(".service")[0].split("-")[-1])
        uptime = get_service_uptime(service_name)
        log = get_service_log(service_name).split("]:")[1]

        # Retrieve the version information using the get_version function
        version_info = get_version(service_name)

        filtered_services.append({
            "row": row,
            "service_name": service_name, 
            "loaded": loaded, 
            "active": active, 
            "name": name, 
            "node": node,
            "index": index,
            "uptime": uptime,
            "log": log,
            "version_info": version_info  # Include the version information here
        })

        filtered_services.sort(key=lambda x: (x["name"] or "", x["node"] or "", x["index"] or ""))
        for i, service in enumerate(filtered_services):
            service["row"] = i + 1

    return render_template("index.html", services=filtered_services)

@app.route("/install", methods=["GET", "POST"])
def install_node():
    if request.method == "POST":
        brand = request.form["brand"]
        version = request.form["version"]
        user = request.form["user"]
        userSel = request.form["userSel"]
        email = request.form["email"]
        password = request.form["password"]
        nodeindex = request.form["nodeindex"]
        if len(user) == 0:
            user = userSel
        if len(user) > 0:
            subprocess.run([f"./script/install-{brand}-{version}-node.sh", brand, user, email, password, nodeindex])
    return redirect("/")

@app.route("/upgrade/<brand>/<user>/<int:nodeindex>", methods=["POST"])
def upgrade_node(brand, user, nodeindex):
    try:
        subprocess.run(["./script/upgrade-node.sh", brand, user, str(nodeindex)], check=True)
        flash('Node upgraded successfully', 'success')
    except subprocess.CalledProcessError as e:
        flash(f'Node upgrade failed: {e}', 'danger')
    except Exception as e:
        flash(f'An unexpected error occurred: {e}', 'danger')
    return redirect("/")

@app.route("/delete/<brand>/<user>/<int:nodeindex>", methods=["POST"])
def delete(brand, user, nodeindex):
    subprocess.run(["./script/delete-node.sh", brand, user, str(nodeindex)])
    return redirect("/")

@app.route("/stop/<service_name>", methods=["POST"])
def stop_service(service_name):
    subprocess.run(["systemctl", "stop", service_name])
    return redirect("/")

@app.route("/restart/<service_name>", methods=["POST"])
def restart_service(service_name):
    subprocess.run(["systemctl", "restart", service_name])
    return redirect("/")

@app.route("/disable/<service_name>", methods=["POST"])
def disable_service(service_name):
    subprocess.run(["systemctl", "stop", service_name])
    subprocess.run(["systemctl", "disable", service_name])
    return redirect("/")

@app.route("/restartall", methods=["POST"])
def restartall_service():
    subprocess.run(["systemctl", "restart", "*-node-*.service"])
    return redirect("/")

@app.route("/stopall", methods=["POST"])
def stopall_service():
    subprocess.run(["systemctl", "stop", "*-node-*.service"])
    return redirect("/")

if __name__ == "__main__":
    app.run()
