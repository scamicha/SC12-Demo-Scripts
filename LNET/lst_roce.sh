#!/bin/bash

the_usage()
{
        echo >&2
        echo "usage: `basename $0` -c client-nids -s server-nids -r on|off [-d distribute] [-n rpcs] " >&2
	cat <<EOF 2>&1
-c 		max number of client nids to use defaults to 1
-s 		max number of server nids to use defaults to 1
-n rpcs		largest max_rpcs_in_flight, steps through in powers of 2, defaults to 8
-r on|off       use roce or not, defaults to off
-d distribute	distribution, defaults to running matrix


example:
lnet_selftest.sh -c 2 -s 4

EOF
}

 set -x
# log directory
LOGDIR=/tmp/lst_logs

LST=lst

# lst stat time interval
LST_DELAY=20

# lst stat duration
LST_DURATION=25

# max concurrency
LST_CONCUR=8

# max brw size
LST_BRW=1024

# vmstat interval
VM_DELAY=3

#max clients and servers
MAX_CLIENTS=1
MAX_SERVERS=1

#roce setting
ROCE="off"

#Distribution
DISTRIBUTE=1:1

while getopts ":c:s:n:d:r:l" opt; do
        case $opt in
        c)
                max_clients=$OPTARG
                ;;
	d)
		distribute=$OPTARG
                ;;
        s)
                max_servers=$OPTARG
                ;;
        n)	
		lst_concur=$OPTARG
		;;
        r)
		roce=$(echo $OPTARG | tr '[A-Z]' '[a-z]')
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

TCP_CLIENTS="192.168.0.109@tcp 192.168.0.110@tcp 192.168.0.111@tcp 192.168.0.112@tcp"
TCP_SERVERS="192.168.0.101@tcp 192.168.0.102@tcp 192.168.0.103@tcp 192.168.0.104@tcp"

IB_CLIENTS="192.168.0.109@o2ib 192.168.0.110@o2ib 192.168.0.111@o2ib 192.168.0.112@o2ib"
IB_SERVERS="192.168.0.101@o2ib 192.168.0.102@o2ib 192.168.0.103@o2ib 192.168.0.104@o2ib"

if [ "${roce}x" == "onx" ];
then
  CLIENTS= $IB_CLIENTS
  SERVERS= $IB_SERVERS
  LOGDIR=/tmp/roce_lst_logs
elif [ "${roce}x" == "offx" ];
then
  CLIENTS= $TCP_CLIENTS
  SERVERS= $TCP_SERVERS
  LOGDIR=/tmp/tcp_lst_logs
else
  echo "derp!"
  the_usage
  exit 1
fi

rm -rf $LOGDIR
mkdir -p $LOGDIR

echo "$CLIENTS"
echo "$SERVERS"

NCLIENTS=0
for CLI in $CLIENTS; do
        NCLIENTS=$(($NCLIENTS + 1))
done

NSERVERS=0
for SRV in $SERVERS; do
        NSERVERS=$(($NSERVERS + 1))
done

echo "total number of clients is $NCLIENTS"
echo "total number of servers is $NSERVERS"

export LST_SESSION=$$

cleanup () {
	trap 0; echo killing $1 ... ; kill -9 $1 || true;
}

prep_test() {
	# create session and groups
	local T_SRV=$1
	local T_CLI=$2
	
	$LST new_session foobar
	$LST add_group cli $T_CLI
	$LST add_group srv $T_SRV
}

done_test() {
	local T_NAME=$1
	local T_SRV=$2
	local T_CLI=$3

	# run batch
	$LST run
	sleep 1

	# collect outputs
	$LST stat --delay=$LST_DELAY $T_SRV > $LOGDIR/$T_NAME.srv &
	$LST stat --delay=$LST_DELAY $T_CLI > $LOGDIR/$T_NAME.cli &
	LST_PID=$!

	# sleep for a while and kill stat process
	sleep $LST_DURATION
	
	echo "kill lst stat..."
	cleanup $LST_PID

	# end the session
	$LST end_session
}

# iterate over power2
# NB: the loop will take a few hours (less than 5)

for (( i=1; i <= $MAX_CLIENTS; i=$(($i * 2)))) ; do
    for (( j=1; j <= $MAX_SERVERS; j=$(($j * 2)))); do

        NCLI=0
        TEST_CLI=

	# get $i clients
        for CLI in $CLIENTS; do
            TEST_CLI="$TEST_CLI $CLI"
	    
            NCLI=$(($NCLI + 1))
            if [ $NCLI = $i ]; then
                break;
            fi
        done

        echo $TEST_CLI

	NSRV=0
	TEST_SRV=

	# get $j servers
        for SRV in $SERVERS; do
                TEST_SRV="$TEST_SRV $SRV"

                NSRV=$(($NSRV + 1))
                if [ $NSRV = $j ]; then
                        break;
                fi
        done

        echo $TEST_SRV

	BRW="read write"

	# brw read & write
	for RW in $BRW; do
			# iterate over 1, 2, 4, 8 threads
	    for (( c=1; c <= $LST_CONCUR; c=$(($c * 2)))) ; do
		for (( n=1; n <= $j; n=$(($n * 2)))) ; do
		    TEST_NAME="$RW-${i}cli-${j}srv-${c}concur-dist1:$n"
		
		    echo "running $TEST_NAME ......"
		
#		vmstat $VM_DELAY > $LOGDIR/$TEST_NAME.vmstat &
        	    VMSTAT=$!

		    prep_test "$TEST_SRV" "$TEST_CLI"
		    DISTRIBUTE=1:$n
		    $LST add_test --from cli --to srv --loop 9000000 --concurrency=$c\
 --distribute=$DISTRIBUTE brw $RW size=${LST_BRW}k
		    done_test $TEST_NAME "$TEST_SRV" "$TEST_CLI"
		
		    cleanup $VMSTAT
		done
	    done
	done
    done
done

