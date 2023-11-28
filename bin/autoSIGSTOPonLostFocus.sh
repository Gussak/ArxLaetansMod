#!/bin/bash

#helps cool down cpu on slow PCs
: ${nMinCpuTime:=3} #help
while true;do 
	nWPid="$(xdotool getwindowpid $(xdotool getactivewindow))";
	nPid="$(pgrep -f "^[.]/arx ")";
	ps -o pid,cputimes,stat,cmd -p $nWPid $nPid&&:
	
	if [[ -z "$nWPid" ]];then nWPid=-1;fi
	declare -p nWPid nPid&&:
	
	#if [[ -n "$nWPid" ]] && [[ -n "$nPid" ]];then
	if [[ -n "$nPid" ]];then
		nCpuTime=$(ps --no-headers -o cputimes -p $nPid |tr -d ' ') 
		if((nCpuTime<nMinCpuTime));then #nCpuTime is to let the window open
			set -x;kill -SIGCONT $nPid;set +x
		else
			#if((nPid==nWPid));then #nCpuTime is to let the window open
			if [[ "$nPid" == "$nWPid" ]];then #nCpuTime is to let the window open
				set -x;kill -SIGCONT $nPid;set +x
			#elif((nCpuTime >= nMinCpuTime));then
			else
				set -x;kill -SIGSTOP $nPid;set +x
			fi
		fi;
	fi
	sleep 2;
done
