#!/bin/sh
# Start

LOG_FILE=/home/hs/server/log/monitor.log
while [ 1 ]
do

reset=0

#i1=`ps -A| grep IrServer.out | grep -v grep | awk '{print $2}'|wc -l`

i1=` pgrep -f server_monitor |wc -l`

if [ $i1 -eq 0 ];then
 
   echo "restart server_monitor.sh!"
   killall server_monitor.sh
   cd /home/hs/server/
   ./server_monitor.sh &
   sleep 5
  echo server_monitor restart on `date` >> $LOG_FILE
fi


#i2=` pgrep -f dev_monitor |wc -l`
#if [ $i2 -eq 0 ];then
# 
#   echo "restart dev_monitor.sh!"
#   killall dev_monitor.sh
#   cd /home/hs/server/
#   ./dev_monitor.sh &
#   sleep 5
#  echo dev_monitor restart on `date` >> $LOG_FILE
#fi

   sleep 30
done
