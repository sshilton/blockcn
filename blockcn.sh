#!/bin/bash
### BEGIN INIT INFO
# Provides:          blockcn
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Should-Start:      $network $named $syslog $time cpufrequtils
# Should-Stop:       $network $named $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: manage the blocking of china and russia
# Description:       blocking ru and china
#                    It is a small daemon which collects system information
#                    periodically and provides mechanisms to monitor and store
#                    the values in a variety of ways.
### END INIT INFO


# Purpose: Block all traffic from AFGHANISTAN (af) and CHINA (CN). Use ISO code. #
# See url for more info - http://www.cyberciti.biz/faq/?p=3402
# Author: nixCraft <www.cyberciti.biz> under GPL v.2.0+
# -------------------------------------------------------------------------------
ISO="af cn ru fn" 
 
### Set PATH ###
IPT=/sbin/iptables
WGET=/usr/bin/wget
EGREP=/bin/egrep
 
### No editing below ###
SPAMLIST="countrydrop"
ZONEROOT="/root/iptables"
DLROOT="http://www.ipdeny.com/ipblocks/data/countries"
 
case "$1" in
	start)
cleanOldRules(){
$IPT -F
$IPT -X
$IPT -t nat -F
$IPT -t nat -X
$IPT -t mangle -F
$IPT -t mangle -X
$IPT -P INPUT ACCEPT
$IPT -P OUTPUT ACCEPT
$IPT -P FORWARD ACCEPT
}
 
# create a dir
[ ! -d $ZONEROOT ] && /bin/mkdir -p $ZONEROOT
 
# clean old rules
cleanOldRules
 
# create a new iptables list
$IPT -N $SPAMLIST
 
for c  in $ISO
do 
	# local zone file
	tDB=$ZONEROOT/$c.zone
 
	# get fresh zone file
	$WGET -O $tDB $DLROOT/$c.zone
 
	# country specific log message
	SPAMDROPMSG="$c Country Drop"
 
	# get 
	BADIPS=$(egrep -v "^#|^$" $tDB)
	for ipblock in $BADIPS
	do
	   $IPT -A $SPAMLIST -s $ipblock -j LOG --log-prefix "$SPAMDROPMSG"
	   $IPT -A $SPAMLIST -s $ipblock -j DROP
	done
done
 
# Drop everything 
$IPT -I INPUT -j $SPAMLIST
$IPT -I OUTPUT -j $SPAMLIST
$IPT -I FORWARD -j $SPAMLIST
 
# call your other iptable script
# /path/to/other/iptables.sh
	;;
stop)
echo "Doing nothing, shutting down"
	;;
status)
sudo 	iptables -L
	;;
*)
	echo "Usage: $0 (start|stop|status)"
	;;
esac
exit 0
