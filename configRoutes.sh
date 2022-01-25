#!/bin/bash

cd ~/RequiredForPICONFIG

INDEX=0
#Since this is a generic script that we put in every pi, we don't know the 
#exact name of the pi config file that we are reading from. So we need to
#find it and use a wildcard in place for the pi number that we don't know.
configFile=$(find . -type f -name "pi*config.txt")

#Reads every line from config file. The first argument is the source node
#If the length of the path is 2, that means that we only have 2 nodes in
#that path, which is the source node directly connected to the destination
#node.
#If the length of the path is greater than 2, that means that we are using
#a gateway to get to the destination. In the path, the gateway node is always
#the node closest to the source. Ex. If we have the path 1 2 3 4, that means
#1 is the source node and 4 is the destination. The gateway is 2 because it
#is closest to the source node (its nexthop)

#Read each line from config file
while IFS= read -r line
do
	#If we reverse the path, the destination is always the last element
	(( destination=$(echo $line | rev | cut -d " " -f1) ))
	
	#The source is either itself, or a gateway
	if [ $(echo $line | wc -w ) == 2 ]
	then
		(( source=$(echo $line | cut -d " " -f1) ))
	else
		(( source=$(echo $line | cut -d " " -f2) ))
	fi

	#Enter sources and destinations into routing table
	echo UMSLPi | sudo -S ip route add "10.0.0.$destination" via "10.0.0.$source"	
	
	#output for user, to narrate that we are entering desired route entry
	echo "Entering route 10.0.0.$destination via 10.0.0.$source in pi $(hostname -I)"

	#echo $line
done < <(tail -n "+2" $configFile)
