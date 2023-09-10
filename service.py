# Copyright (C) 2023 Tommy H. Smith
from flask import Flask, render_template, request, redirect, Response
from dateutil.parser import parse
from time import sleep
import subprocess
import re
import datetime

app = Flask(__name__)

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
        #name = service_name.split("-node-")[1].split(".service")[0].split("-")[0].title()
        name = service_name.split("-node-")[1].split(".service")[0].split("-")[0]
        node = service_name.split("-node-")[0].title()
        index = int(service_name.split("-node-")[1].split(".service")[0].split("-")[-1])
        uptime = get_service_uptime(service_name)
        log = get_service_log(service_name).split("]:")[1]
        filtered_services.append({
            "row": row,
            "service_name": service_name, 
            "loaded": loaded, 
            "active": active, 
            "name": name, 
            "node": node,
            "index": index,
            "uptime": uptime,
            "log": log
        })
        filtered_services.sort(key=lambda x: (x["name"] or "", x["node"] or "", x["index"] or ""))
        for i, service in enumerate(filtered_services):
            service["row"] = i + 1
    return render_template("index.html", services=filtered_services)

@app.route("/install", methods=["GET", "POST"])
def install_node():
    if request.method == "POST":
        brand = request.form["brand"]
        user = request.form["user"]
        userSel = request.form["userSel"]
        email = request.form["email"]
        password = request.form["password"]
        nodeindex = request.form["nodeindex"]
        if len(user) == 0:
            user = userSel
        if len(user) > 0:
            subprocess.run([f"./script/install-{brand}-node.sh", brand, user, email, password, nodeindex])
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
