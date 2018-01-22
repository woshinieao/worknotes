#!/bin/sh
# Start
#setsid sh server_monitor.sh &

LOG_FILE=/home/hs/server/log/server_monitor.log

mkdir -p /home/hs/server/log
while [ 1 ]
do

reset=0

i1=`ps -A| grep IrServer.out | grep -v grep | awk '{print $2}'|wc -l`

i1=` pgrep -f server_monitor |wc -l`
if [ $i1 -eq 0 ];then
 
   echo "restart server_monitor.sh!"
   killall server_monitor.sh
   cd /home/hs/server/
   chmod +x server_monitor.sh
   ./server_monitor.sh &
   sleep 5
  echo server_monitor restart on `date` >> $LOG_FILE
fi
sleep 30

done
