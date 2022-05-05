#!/bin/sh

killall oscam
killall mgcamd
killall wicardd

emu=`cat /usr/bin/cam/setemu`

if [ $emu == "oscam" ]; then
/usr/bin/cam/oscam -c /var/keys &
fi
if [ $emu == "mgcamd" ]; then
/usr/bin/cam/mgcamd -c /var/keys &
fi
if [ $emu == "wicardd" ]; then
/usr/bin/cam/wicardd /var/etc/wicardd.conf & 
fi
