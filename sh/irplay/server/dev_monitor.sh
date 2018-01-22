#!/bin/bash
LOG_PATH=/home/hs/server/log
SERVER_LOG=$LOG_PATH/dev_monitor.log
test -d LOG_PATH || mkdir -p LOG_PATH -m 775
chown hs:hs LOG_PATH

while [ 1 ]
do
    neterror=$(/bin/netstat -an | grep -cw "CLOSE_WAIT")

    if [ $neterror -gt "50" ]; then
        /bin/date >> $SERVER_LOG
        echo "Neterror(CLOSE_WAIT numbers):"$neterror >> $SERVER_LOG
        echo "The server computer will restart now!" >> $SERVER_LOG
        echo >> $SERVER_LOG
        sleep 2
        /sbin/reboot -f
    fi

    freememory=$(free -m | grep Mem | awk '{print $4 + $6 + $7}')
    /bin/date >> $SERVER_LOG
    echo "Free memory[M]:"$freememory >> $SERVER_LOG
    echo >> $SERVER_LOG

    if [ $freememory -lt "100" ]; then
        /bin/date >> $SERVER_LOG
        echo "Free memory(useful memory size[M]):"$freememory >> $SERVER_LOG
        echo "The free memory size is to low,reboot now!" >> $SERVER_LOG
        echo >> $SERVER_LOG
        sleep 2
        /sbin/reboot -f
    fi

    cachesmemory=$(free -m | grep Mem | awk '{print $7}')
    /bin/date >> $SERVER_LOG
    echo "caches memory[M]:"$cachesmemory >> $SERVER_LOG
    echo >> $SERVER_LOG

    if [ $cachesmemory -gt "2000" ]; then
        /bin/date >> $SERVER_LOG
        echo "cachesmemory [M]):"$cachesmemory>> $SERVER_LOG
        echo "The free cachesmemory!" >> $SERVER_LOG
        echo >> $SERVER_LOG
        sync; echo 3 > /proc/sys/vm/drop_caches
        sleep 2
    fi

    corpsprocess=$(ps -ef | awk '{print $3$4}' | grep -c "Z")

    if [ $corpsprocess -gt "10" ]; then
        /bin/date >> $SERVER_LOG
        echo "Corpsprocess(zombie process numbers):"$corpsprocess >> $SERVER_LOG
        echo "System had corps process,system will reboot now!" >> $SERVER_LOG
        echo >> $SERVER_LOG
        sleep 2
        /sbin/reboot -f
    fi

    sleep 60
done
