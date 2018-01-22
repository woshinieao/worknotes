#!/bin/bash

upfile="/var/www/media/update/update.zip"
tmpfile="/home/hs/bakfile/update"
echo "update start....."
mkdir -p /home/hs/bakfile

if [ -f "$upfile" ];then
   cp /var/www/media/update/update.zip /tmp
   unzip -o /tmp/update.zip -d $tmpfile
    cd $tmpfile
    if [ -f "run.sh" ];then
	chmod +x run.sh
	./run.sh
       
    fi
#    rm -rf $tmpfile
echo "update stop....."
fi
