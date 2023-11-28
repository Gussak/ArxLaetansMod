#!/bin/bash

cd "`dirname "$0"`"
#(xterm -e git gui & disown)
#(git gui & disown)
(xterm -e bash -c "sleep 1;(nohup git gui & disown);sleep 1"&disown)
read -t 60 -n 1 -p PressAKeyToExit
