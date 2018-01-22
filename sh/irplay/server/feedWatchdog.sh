#!/bin/bash
#oprate the watchdog.

/usr/sbin/wdt -e -r -t 300
 
while [ 1 ]
do
	/usr/sbin/wdt -r
	sleep 100
done

