#!/bin/bash

#helps cool down cpu on slow PCs
: ${nMinCpuTime:=3} #help
while true;do 
	nWPid="$(xdotool getwindowpid $(xdotool getactivewindow))";
	nPid="$(pgrep -f "^[.]/arx ")";
	declare -p nWPid nPid&&:
	ps -o pid,cputimes,stat,cmd -p $nWPid $nPid&&:
	
	if [[ -n "$nWPid" ]] && [[ -n "$nPid" ]];then
		nCpuTime=$(ps --no-headers -o cputimes -p $nPid |tr -d ' ') 
		if((nPid==nWPid || nCpuTime<nMinCpuTime));then #nCpuTime is to let the window open
			kill -SIGCONT $nPid;
		else
			if((nCpuTime >= nMinCpuTime));then
				kill -SIGSTOP $nPid;
			fi
		fi;
	fi
	sleep 2;
done
