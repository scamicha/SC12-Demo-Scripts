#!/bin/bash

lsscsi | grep DDN.*sd | awk -F/ '{print $NF}' | while read dev; do echo 0 > /sys/block/$dev/queue/read_ahead_kb; done

for dm in $(ls -d /sys/fs/ldiskfs/dm*)
do
  echo 512 > ${dm}/mb_group_prealloc
  echo 512 > ${dm}/mb_large_req
  echo 1 > ${dm}/mb_small_req
  echo 1 > ${dm}/inode_readahead_blks
done

echo 256 > /proc/fs/lustre/ost/OSS/ost_io/threads_min
echo 256 > /proc/fs/lustre/ost/OSS/ost/threads_min

lctl set_param obdfilter.*.sync_journal=0
lctl set_param obdfilter.*.read_cache_enable=0
lctl set_param debug=0
