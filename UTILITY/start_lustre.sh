#!/bin/bash

modprobe lnet
sleep 2
modprobe lustre
sleep 2
modprobe ksocklnd
echo -n "Mount lustre? (y/n): "
read answer
if [ "${answer}x" == "yx" ];
then
  retval=$(/opt/ddn/bin/es_mount | grep -i error)
  if [ "${retval}x" != "x" ];
  then
    echo "Errored once, trying once again"
    /opt/ddn/bin/es_mount
  fi
fi
