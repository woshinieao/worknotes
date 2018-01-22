#!/bin/sh
# Start
#setsid sh server_monitor.sh &

LOG_FILE=/home/hs/neo/sh/log/serPublish.log

mkdir -p /home/hs/neo/sh/log
touch $LOG_FILE

while [ 1 ]
do

reset=0


i1=` pgrep -f serPublish |wc -l`
if [ $i1 -eq 0 ];then

   
   killall -9 serPublish.sh
   cd /home/hs/neo/sh
   chmod +x serPublish.sh
   ./serPublish.sh &
    echo "serPublish restart "
   sleep 5
  echo serPublish  restart on `date` >> $LOG_FILE
fi
sleep 30

done

