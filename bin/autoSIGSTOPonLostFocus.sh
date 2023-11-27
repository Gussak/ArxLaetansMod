#!/bin/bash

#helps cool down cpu on slow PCs
while true;do 
	nWPid="$(xdotool getwindowpid $(xdotool getactivewindow))";
	nPid="$(pgrep -f "^[.]/arx ")";
	ps -p $nWPid $nPid&&:;
	
	if [[ -n "$nWPid" ]] && [[ -n "$nPid" ]];then
		if((nPid==nWPid));then 
			kill -SIGCONT $nPid;
		else 
			kill -SIGSTOP $nPid;
		fi;
	fi
	sleep 2;
done
