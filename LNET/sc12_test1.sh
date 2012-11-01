#!/bin/sh 
 
#echo "You need to manually load lnet_selftest on all nodes"
#echo "modprobe lnet_selftest"

the_usage()
{
        echo >&2
        echo "usage: `basename $0` -c client-nids -s server-nids [-n rpcs] [-d distribute] [-t prefix]" >&2
	cat <<EOF 2>&1
-c 		client nids
-s 		server nids
-n rpcs		max_rpcs_in_flight, defaults to 8
-d distribute	distribution, defaults to 1:1
-t output file prefix	default to test

example:
lnet_selftest.sh -c "10.10.100.223@o2ib 10.10.100.224@o2ib" \
 -s "10.10.100.215@o2ib 10.10.100.216@o2ib" 

EOF
}

concurent=8 # 8 rpcs in flight by default
distribute=1:1
prefix=test
while getopts ":c:s:n:d:t:l" opt; do
        case $opt in
        c)
                clients="$OPTARG"
                ;;
	d)
		distribute=$OPTARG
                ;;
        s)
                servers="$OPTARG"
                ;;
	t)	
		prefix=$OPTARG
		;;
	n)	
		concurent=$OPTARG
		;;
        :)      
                echo "Option -$OPTARG requires an argument." >&2
                the_usage 
                exit 1
                ;;
        *)
                echo "Invalid option: -$OPTARG" >&2
                the_usage
                exit 1
                ;;
        esac
done

if [ -z "$clients" -o -z "$servers" ];then 
	the_usage
	exit 1
fi

for (( rpcinflight=1; rpcinflight <= 64; rpcinflight=$(($rpcinflight * 2)))); do
	resultFile=./$prefix\_$rpcinflight\_$distribute\.log
	rm $resultFile

	echo "RPCs in Flight:" $rpcinflight
	echo "Read"
	echo "RH RPCsInFlight "$rpcinflight >>$resultFile
	echo "RH Read " >>$resultFile
	export LST_SESSION=$$ 
	trap "lst end_session" SIGINT SIGTERM 
	echo "LST_SESSION=$LST_SESSION" 
	lst new_session read/write > /dev/null
	lst add_group servers $servers > /dev/null
	lst add_group readers $clients > /dev/null
	lst add_test --from readers --to servers brw read size=1M --distribute $distribute --concurrency $rpcinflight >/dev/null
	lst run >/dev/null
	sleep 1
	#lst stat --delay=8 servers > $resultFile &
	lst stat --delay=8 $clients >>$resultFile &
	LST_PID=$!
	# sleep for a while and kill stat process
	sleep 10
#	echo "kill lst stat..."
	trap 0; echo killing $LST_PID ... >/dev/null ; kill -9 $LST_PID || true;
	# end the session
	lst end_session >/dev/null

	echo "Write"
	echo "RH Write " >>$resultFile
	export LST_SESSION=$$ 
	trap "lst end_session" SIGINT SIGTERM 
	echo "LST_SESSION=$LST_SESSION" 
	lst new_session read/write > /dev/null
	lst add_group servers $servers > /dev/null
	lst add_group readers $clients > /dev/null
	lst add_test --from readers --to servers brw write size=1M --distribute $distribute --concurrency $rpcinflight >/dev/null
	lst run >/dev/null
	sleep 1
	#lst stat --delay=8 servers > $resultFile &
	lst stat --delay=8 $clients >>$resultFile &
	LST_PID=$!
	# sleep for a while and kill stat process
	sleep 10
#	echo "kill lst stat..."
	trap 0; echo killing $LST_PID ... >/dev/null ; kill -9 $LST_PID || true;
	# end the session
	lst end_session >/dev/null


done

exit

#old stuff

# comment out any of these two if you don't want to duplex performance 
if [ $writes_only -eq 0 ]; then
	lst add_test --from readers --to servers brw read size=1M --concurrency $concurent
fi

