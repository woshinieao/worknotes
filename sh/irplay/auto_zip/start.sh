#!/bin/sh
# Start
#setsid sh server_monitor.sh &

#LOG_FILE=/home/hs/neo/log/serPublish.log

#mkdir -p /home/hs/neo/log
#touch serPublish.log
while [ 1 ]
do



i1=` pgrep -f start_serPub.sh |wc -l`
if [ $i1 -eq 0 ];then

   
   killall -9 start_serPub.sh
   cd /home/hs/neo/sh
   chmod +x start_serPub.sh
   ./start_serPub.sh &
    echo "start_serPub restart "
   sleep 5
fi
sleep 30

done

