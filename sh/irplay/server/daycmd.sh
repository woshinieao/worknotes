#!/bin/sh
service mysqld restart
killall IrServer.out
/home/hs/server/IrServer.out &
echo `date` >> /home/hs/server/test.txt

