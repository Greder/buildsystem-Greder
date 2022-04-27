#!/bin/sh

killall oscam
killall mgcamd
killall wicardd-sh4

emu=`cat /usr/bin/cam/setemu`

if [ $emu == "oscam" ]; then
/usr/bin/cam/oscam -c /var/keys &
fi
if [ $emu == "mgcamd" ]; then
/usr/bin/cam/mgcamd -c /var/keys &
fi
if [ $emu == "wicardd-sh4" ]; then
/usr/bin/cam/wicardd-sh4 /var/keys/wicardd.conf & 
fi
