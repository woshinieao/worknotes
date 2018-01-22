#!/bin/bash

fixTime=
preTime=0



check(){    
    fixTime=`stat -c %Y IrServer.out`
    if [ "$fixTime" -ne "$preTime" ];then
        chmod a+x /home/hs/publish/publish.sh
        /home/hs/publish/publish.sh > /dev/null
        preTime=$fixTime
        echo " file change"
    else
        echo "fix:" $fixTime > /dev/null
        echo "fix:" $fixTime > /dev/null
    fi
    
}



while [ 1 ]
do  
cd /home/hs/server
    if [ -f "IrServer.out" ];then  
        check
    fi

    sleep 5

done
