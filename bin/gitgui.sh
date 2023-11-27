#!/bin/bash

cd "`dirname "$0"`"
(xterm -e git gui & disown)
read -t 60 -n 1 -p PressAKeyToExit
