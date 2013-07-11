#!/bin/bash
HOSTS="google.com other.host.com"
COUNT=4 # ping count
LIMIT=2 # ping failed limit

MAILFILE="/tmp/bot_ping.mail" # temp file for email
MAILTITLE="Bot Ping Alert"
DEST="admin@host.com other@host.com"

echo "" > $MAILFILE
for myHost in $HOSTS
do
    count=$(ping -c $COUNT $myHost | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')

    if [ $count -le $LIMIT ]; then
        if [ ! -e "/tmp/$myHost" ]; then
            # 100% failed 
            echo "Host : $myHost is down (ping failed) at $(date)" >> $MAILFILE
            touch /tmp/$myHost
        fi
    else
        if [ $count -eq $COUNT ]; then
            if [ -e "/tmp/$myHost" ]; then
                echo "Host : $myHost is UP ! at $(date)" >> $MAILFILE
                rm -f "/tmp/$myHost"
            fi
        fi
    fi
done

for dest in $DEST
do
    mail -E -s "$MAILTITLE" $dest < $MAILFILE
done
