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

echo "Netcat server started on port $ncport."
while true
do
    nc -l -p $ncport > $shawtydfifo
done

echo "Netcat server ended."
