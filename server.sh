#!/bin/bash
#################################################
#   shawtyd netcat server
#       Forwards data sent to port 31337 to 
#       the shawtyd fifo. Allows for setting the
#       whitelisted ip remotely.
#################################################
if [[ "$(id -u)" -eq "0" ]]; then
   echo "You don't want to run this as root" 1>&2
   exit 1
fi

### Config
ncport=31337
shawtydfifo=/tmp/shawtydfifo
### End Config

res="HTTP/1.1 200 OK
Server: Apache/2.2.3 (Red Hat)
Connection: close
Content-Type: text/html; charset=utf-8
Content-Length: 136

<html><head><title>ADMIN PANEL</title></head><body><br><h1>Error</h1><hr>Your ip is banned. This incident has been looged.</body></html>"

echo "Netcat server started on port $ncport."
while true
do
    msg=$(echo "$res" | nc -l -p $ncport)
    count=$(echo "$msg" | wc -l)
    if [[ "count" -eq "1" ]];then
        echo "$msg" > $shawtydfifo
    else
        echo "$msg" | while read line; do
            case $line in
                GET*)
                    echo "$line" | awk '{print $2}' | awk -F '/' '{print $2 " " $3}' > $shawtydfifo
                    ;;
            esac
        done
    fi
done

echo "Netcat server ended."
