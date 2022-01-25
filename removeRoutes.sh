#!/bin/bash
cd ~/RequiredForPICONFIG
#Get all routes with subnet 10.0.0. Do not include address 10.0.0.0, because this is our default route
#awk $1 gets the first argument of every line, which is the Destination IP address
myVar=$(netstat -rn | awk '/10.0.0/ {print}' | awk '! /10.0.0.0/ {print $1}')
INDEX=1
echo "Removing config file $(find ~/RequiredForPICONFIG -type f -name 'pi*config.txt')"
find ~/RequiredForPICONFIG -type f -name 'pi*config.txt' -delete

#loop through each line in routing table (lines are saved in variable called myVar)
for i in $myVar;
	#For each line in routing table,
do
	echo UMSLPi | sudo -S ip route delete $i
	echo "Deleting route $i in pi $(hostname -I)"
done
