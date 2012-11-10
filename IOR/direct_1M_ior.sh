#!/bin/bash

echo RPC STRIPE MB/sec
for RPC in 08 128 256 
do
    for OST in 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 
    do
	echo "$RPC" >>/proc/fs/lustre/osc/luram-OST00$OST-osc-ffff810639aac800/max_rpcs_in_flight
    done
    for STRIPE in 01 02 04
    do
	for POOL in 01 02 03 04
	do
	    lfs setstripe -c $STRIPE -p oss$POOL ./data/file.00$POOL
	    ./IOR -f direct_1M_script 1>>out_ior_50G_1M_1Proc_$RPC\_$STRIPE.txt 2>/dev/null
	    lfs getstripe data/ >>out_ior_50G_1M_1Proc_$RPC\_$STRIPE.txt_stripe
	    rm data/*
	    TEXT=`cat out_ior_50G_1M_1Proc_$RPC\_$STRIPE.txt| grep "Max Write" | awk '{print $3}'`
	    echo $RPC $TEXT
	done
    done
done
