#!/bin/sh
./monitor.sh &
./server_monitor.sh &
./dev_monitor.sh  &
./feedWatchdog.sh &

