#!/bin/bash 

cd ~/RequiredForPICONFIG
#Get the first column of routing table entries, which are the Destination IP addresses
#awk $1 gets the first argument of every line
myVar=$(netstat -rn | awk '/10.0.0/ {print}'| awk '! /10.0.0.0/ {print $1}')
#declare PING_TIMES
INDEX=1

#loop through each line in routing table (Lines are saved i variable caleld myVar)
for i in $myVar;
#For each line in routing table,
do
		host_id=${i: -1}	
		#echo $host_id	

		outputFile="./Plots/scp${i}.dat"
		echo "${outputFile} ...Entering data..."
		
		touch $outputFile	

		outputFileFinal="./Plots/scpOutputFinal${i}.dat"
		
		TIMEFORMAT=%R;
		#The bash time function writes its output to STDERR rather rthan STDOUT. In order to redirect 'time's' output, we must capture stderr of the subshell which contain time's results. Here, we are saying stream '2' is redirected to /dev/null because we don't need the output from the scp command itself. Rather, we need the ouput of time, which is stream 1. 2>&1 saves stream 1 into the variable scp_time.
		scp_time=$(time ( scp ./Plots/100bytes.txt epharra${host_id}@${i}:~/Documents 2>/dev/null 1>&2 ) 2>&1 )
		printf "100bytes\t%s" ${scp_time} > $outputFile
		scp_time2=$(time ( scp ./Plots/10000bytes.txt epharra${host_id}@${i}:~/Documents 2>/dev/null 1>&2 ) 2>&1 )
		printf "\n10000bytes\t%s"  ${scp_time2} >> $outputFile
		scp_time3=$(time ( scp ./Plots/1000000bytes.txt epharra${host_id}@${i}:~/Documents 2>/dev/null 1>&2 ) 2>&1 )
		printf "\n1000000bytes\t%s" ${scp_time3} >> $outputFile

		awk '{ print NR"\t", $0 }' $outputFile > $outputFileFinal
				
		rm $outputFile
		
		#Create gnuplot scripts to graph results of each scp destination result
		#Write gnuplot scp script to file
		printf "set terminal png" >> ./Plots/gnuplotScpScript.gp
		printf "\nset output \"./Plots/gnuplotScpTo"%s".png\"" $i >> ./Plots/gnuplotScpScript.gp
		printf "\nset title \"Scp test results to "%s"\"" $i >> ./Plots/gnuplotScpScript.gp
		printf "\nshow title" >> ./Plots/gnuplotScpScript.gp
		printf "\nset xlabel \"file size\"" >> ./Plots/gnuplotScpScript.gp
		printf "\nset ylabel \"time in ms\"" >> ./Plots/gnuplotScpScript.gp
		printf "\nset boxwidth 0.5" >> ./Plots/gnuplotScpScript.gp
		printf "\nset style fill solid" >> ./Plots/gnuplotScpScript.gp
		printf "\nplot \"./"%s"\" using 1:3:xtic(2) with boxes" $outputFileFinal >> ./Plots/gnuplotScpScript.gp
		printf "\nexit" >> ./Plots/gnuplotScpScript.gp

		gnuplot -p ./Plots/gnuplotScpScript.gp

		rm ./Plots/gnuplotScpScript.gp		
done
