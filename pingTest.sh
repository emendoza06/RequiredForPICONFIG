#!/bin/bash 

cd ~/RequiredForPICONFIG
#Get the first column of routing table entries, which are the Destination IP addresses
#awk $1 gets the first argument of every line
myVar=$(netstat -rn | awk '/10.0.0/ {print}'| awk '! /10.0.0.0/ {print $1}')
ping_count_custom=$(awk 'NR==1 {print; exit}' pi*config.txt)
echo $ping_count_custom

INDEX=1

#loop through each line in routing table (Lines are saved in variable called myVar)
for i in $myVar;
#For each line in routing table,
do
	#PING_TIMES pipes:
	#Pipe 1: each destination ip address 10x

	#Pipe 2: use awk function which scans each output line. Search for any line that contains the string 'time' and 'icmp_seq'. These lines 		contain the rtt time we need

	#Pipe 3: Now we have a line that looks like this: 64 bytes from 10.0.0.x: icmp_seq=1 ttl=64 time=2.00 ms. From this line, we only need the decimal value after time=2.00. We will use  awk -F, which creates a field separator, which is separated by '='. Once we have separated time from 2.00, then we will get the second argument, $2, which is the decimal value.
		#save ping destination ip addresses into array for gnuplot labeling 
	
		
	
		outputFile="./Plots/pingOutput${i}.dat"
		echo "${outputFile} ...Entering data..."
		
		touch $outputFile	

		outputFileFinal="./Plots/pingOutputFinal${i}.dat"
		
		ping -c $ping_count_custom $i | awk '/time/ && /icmp_seq/ {print}' | awk '{print $7}' | awk -F= '{print $2}' > $outputFileFinal

		avg_rtt=$(awk '{sum+=$1} END {print sum/NR}' $outputFileFinal)

		#echo $avg_rtt

		
		awk '{ print NR"\t", $0 }' $outputFileFinal > $outputFile
			
		#add avg_rtt to files
		awk -v avgrtt=$avg_rtt '{print $0"\t " avgrtt}' $outputFile > $outputFileFinal
		
		rm $outputFile
		
		#Create gnuplot scripts to graph results of each ping destination result
		#Write gnuplot ping script to file
		printf "set terminal png" >> ./Plots/gnuplotPingScript.gp
		printf "\nset output \"./Plots/gnuplotPingTo"%s".png\"" $i >> ./Plots/gnuplotPingScript.gp
		printf "\nset title \"Ping test results to "%s"\"" $i >> ./Plots/gnuplotPingScript.gp
		printf "\nshow title" >> ./Plots/gnuplotPingScript.gp
		printf "\nset xlabel \"ping count\"" >> ./Plots/gnuplotPingScript.gp
		printf "\nset ylabel \"time in ms\"" >> ./Plots/gnuplotPingScript.gp
		printf "\nplot \"./"%s"\" using 1:2 w lp title \"rtt of each ping\",\\" $outputFileFinal >> ./Plots/gnuplotPingScript.gp
		printf "\n\t\"./"%s"\" using 1:3 w lp title \"avg rtt\"" $outputFileFinal >> ./Plots/gnuplotPingScript.gp
		printf "\nexit" >> ./Plots/gnuplotPingScript.gp

		gnuplot -p ./Plots/gnuplotPingScript.gp

		rm ./Plots/gnuplotPingScript.gp		
done
