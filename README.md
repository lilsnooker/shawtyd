
shawtyd
======================
Somebody call 911! Shawty firewall burning on the network.

About
======================
A very simple iptables firewall script designed to work somewhat like a port knocker. The firewall blocks selected ports except for a whitelisted ip.

The whitelisted ip can be set through sending a command to a fifo file. (eg `echo "whitelist 127.0.0.1" > /tmp/shawtydfifo`)

server.sh is a simple server to allow updating the whitelisted ip over a network. (eg `echo "whitelist 127.0.0.1" | nc server.com 31337`)

Usage
======================
First start the firewall (requires root)
```
sudo ./shawtyd.sh
```
Then the netcat server if you are interested
```
./server
```
