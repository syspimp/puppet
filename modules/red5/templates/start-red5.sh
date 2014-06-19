#!/bin/bash
RED5_HOME=/opt/red5

function start()
{
pushd $RED5_HOME
JAVA_HOME=/usr/bin/jdk1.6.0_24
/opt/red5/red5.sh >> /opt/red5/log/red5-console.log 2>&1 &
popd
}
function stop()
{
CHECK="$(ps ax|grep red5|grep -v grep|grep -v $0)"
if [ ! -z "$CHECK" ]
then
        pid=$(echo $CHECK | awk '{print $1}')
        echo -n "Killing red5 $pid ... "
        kill -HUP $pid
        if [ $? -eq 0 ]
        then
                echo "OK"
        else
                echo "FAIL"
        fi
else
        echo "red5 not running, or can't find pid"
        exit 1
fi
}
function status()
{
CHECK="$(ps ax|grep red5|grep -v grep|grep -v $0)"
if [ ! -z "$CHECK" ]
then
	echo "Red5 is running ..."
	echo $CHECK
	exit 0
else
	echo "Red5 is not running ..."
	exit 1
fi
}
case "$1" in
        start)  start
        ;;
        stop)   stop
        ;;
	status)	status
	;;
        *)      echo "$0 status, start or stop"
        ;;
esac

