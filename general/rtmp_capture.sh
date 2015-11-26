#!/bin/sh
echo Try downloding the stream that will appear here, or use rtmpsuck
sudo iptables -t nat -A OUTPUT -p tcp --dport 1935 -j REDIRECT
sudo rtmpsrv
sudo iptables -t nat -D OUTPUT -p tcp --dport 1935 -j REDIRECT
