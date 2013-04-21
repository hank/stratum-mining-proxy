#!/bin/bash
### BEGIN INIT INFO
# Provides:          stratum-mining-proxy
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start/stop stratum-mining-proxy daemon
### END INIT INFO
NAME=stratum-mining-proxy
USER=hank # username to run under
SCRIPTS="/home/hank/repos/stratum-mining-proxy/run_coinotron.sh 
	/home/hank/repos/stratum-mining-proxy/run_euwemineltc.sh 
	/home/hank/repos/stratum-mining-proxy/run_uswemineltc.sh 
	/home/hank/repos/stratum-mining-proxy/run_ozcoin.sh 
	/home/hank/repos/stratum-mining-proxy/run_givemeltc.sh"
SCREEN=/usr/bin/screen # screen binary
SCREEN_NAME=$NAME # screen name 
                  # (this way you can screen -r NAME)
PIDFILE=/var/run/${NAME}.pid # pidfile
case "$1" in
    start)
        echo "Starting ${NAME}."
        start-stop-daemon --start --background --oknodo \
            --pidfile "$PIDFILE" --make-pidfile \
            --chuid $USER \
            --exec $SCREEN -- -DmUS $SCREEN_NAME
        if [[ $? -ne 0 ]]; then
            echo "Error: $NAME failed to start."
            exit 1
        fi
	sleep 0.5
	first=1
	for i in $SCRIPTS; do
		echo "Running $i..."
		if [ $first == 1 ]; then
			sudo -u $USER $SCREEN -S $SCREEN_NAME -p 0 \
			-X exec $i
		else
			sudo -u $USER $SCREEN -S $SCREEN_NAME \
			-X screen $i
		fi
		if [[ $? -ne 0 ]]; then
		    echo "Error: $i failed to start."
		    exit 1
		fi
		first=0
	done
        echo "$NAME started successfully."
        ;;

    stop)
        echo "Stopping ${NAME}."
        start-stop-daemon --stop --oknodo --pidfile "$PIDFILE"
        if [[ $? -ne 0 ]]; then
            echo "Error: failed to stop rtorrent process."
            exit 1
        fi
        echo "$NAME stopped successfully."
        ;;

    restart|force-reload)
        "$0" stop
        sleep 1
        "$0" start || exit 1
        ;;

    *)
        echo "Usage: $0 [start|stop|restart]"
        exit 1
        ;;
esac
