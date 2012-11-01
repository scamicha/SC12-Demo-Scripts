#!/bin/bash

ONOFF=$(echo $1 | tr '[A-Z]' '[a-z]')
LOGFILE=/scratch/log/roce.log

preload ()
{
  if [ ! -d $(dirname ${LOGFILE}) ];
  then 
    mkdir -p $(dirname ${LOGFILE})
  fi
  echo "$(date) $(hostname) Unloading Lustre to change RoCE status" >> ${LOGFILE}
  umount -a -t lustre >> ${LOGFILE} 2>&1
  lctl net down >> ${LOGFILE} 2>&1
  modprobe -r lnet >> ${LOGFILE} 2>&1
  lustre_rmmod >> ${LOGFILE} 2>&1
}
roce_on ()
{
  echo "$(date) $(hostname) Enabling RoCE" >> ${LOGFILE}
  cp -f /etc/ddn/exascaler.conf.roceon /etc/ddn/exascaler.conf
  /opt/ddn/config/lustre/config-modprobe.py >> ${LOGFILE} 2>&1
  /opt/ddn/bin/es_tunefs --writeconf >> ${LOGFILE} 2>&1
}
roce_off ()
{
  echo "$(date) $(hostname) Disabling RoCE" >> ${LOGFILE}
  cp -f /etc/ddn/exascaler.conf.roceoff /etc/ddn/exascaler.conf
  /opt/ddn/config/lustre/config-modprobe.py >> ${LOGFILE} 2>&1
  /opt/ddn/bin/es_tunefs --writeconf >> ${LOGFILE} 2>&1
}

if [ "${ONOFF}x" == "onx" ];
then
  preload
  roce_on
elif [ "${ONOFF}x" == "offx" ];
then
  preload
  roce_off
else
  echo "error: $0 $1"
  echo "  Unknown command line argument: ${ONOFF}"
  echo "  $0 only accepts argument <on|off>"
fi
