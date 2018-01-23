#!/bin/bash

LOG_FILE=/var/www/media/log/monitor.log
upFlag="/var/www/media/update/flag"
upsh="/var/www/media/update/run.sh"

count=1;
log() {
    text="`date +'%Y-%m-%d %H:%M:%S'` $1"
    echo $text
    echo $text >> $LOG_FILE
}

monitor() {
    
    chmod 777 config -R 
    count=`pgrep -f $1 | wc -l`
    if [ $count -eq 0 ]
    then
        log "Restart $1!"
        killall -9 $1
        cd /home/hs/server
        chmod +x $1
        ./$1 &
        sleep 5
    fi
}



log "Start Server Monitor!"

while [ 1 ]
do
	let count++
	echo "count :" $count
	
	if [ -f "$upFlag" ];then
		if [ -f "$upsh" ];then
			
			killall -9 ffmpeg
			killall -9 IrServer.out
			killall -9 gaurd.out
			chmod +x upsh
			upsh
			rm -rf upFlag
			if test -e upFlag
            then
                rm -rf upFlag
            else
                echo "upFlag delete"
	
		fi
	fi
	if [ $count -eq 15 ]
	then
    monitor IrServer.out
    monitor gaurd.out
	
    # 结束运行时间超过一小时的ffmpeg进程
    ps -xc -oetimes,pid,cmd | grep ffmpeg | awk '$1>3600{print $2}' | xargs kill -9
    # modify: 2017/03/08
	let count=1
	#echo "aaa count :" $count
	fi
    sleep 2
done
