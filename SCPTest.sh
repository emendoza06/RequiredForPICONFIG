#!/bin/bash 

#Ensure that we are in the correct directory
cd ~/RequiredForPICONFIG
#Get the first column of routing table entries, which are the Destination IP addresses
#awk $1 gets the first argument of every line. Then, we discard the address 10.0.0.0 because this is our default and we don't plot this.
entries=$(netstat -rn | awk '/10.0.0/ {print}'| awk '! /10.0.0.0/ {print $1}')

#Index for for loop
INDEX=1

#loop through each line in routing table (Lines are saved i variable called entries)
for i in $entries;

#For each line in routing table,
do
		#Get pi number we are scp'ing to. This number is $i, which is 10.0.0.[X]. We just want to take the last character, which is [X]
		host_id=${i: -1}	
		#echo $host_id	
		
		#Create a string name for the outputFile. Store the string into variable outputFile
		outputFile="./Plots/scp${i}.dat"
		echo "${outputFile} ...Entering data..."
		#Create the outputfile
		touch $outputFile	
		
		#Create a string name for the final output file. Store the string into variable outputFileFinal
		outputFileFinal="./Plots/scpOutputFinal${i}.dat"
		
		#Format the result of time to display x.xxx ms.
		TIMEFORMAT=%R;

		#The bash time function writes its output to STDERR rather rthan STDOUT. In order to redirect 'time's' output, we must capture stderr of the subshell which contain time's results. Here, we are saying stream '2' is redirected to /dev/null because we don't need the output from the scp command itself. Rather, we need the ouput of time, which is stream 1. 2>&1 saves stream 1 into the variable scp_time.
		
		#The first time we scp a file, it takes a long time. The first time we call scp, it includes the time it took to find host, and then transfer file. We don't use the data of this first scp call. 
		scp_time_first=$(time ( scp ./Plots/100bytes.txt epharra${host_id}@${i}:~/Documents 2>/dev/null 1>&2 ) 2>&1 )
		
		#scp the 100bytes.txt file again. This time, it will accurately show the time it took to transfer the file.
		scp_time=$(time (scp ./Plots/100bytes.txt epharra${host_id}@${i}:~/Documents 2>/dev/null 1>&2 ) 2>&1 )
		#Store results
		printf "100bytes\t%s" ${scp_time} > $outputFile
		
		#scp file 2 and append results to outputFile
		scp_time2=$(time ( scp ./Plots/10000bytes.txt epharra${host_id}@${i}:~/Documents 2>/dev/null 1>&2 ) 2>&1 )
		printf "\n10000bytes\t%s"  ${scp_time2} >> $outputFile

		#scp file 3 and append results to outputFile
		scp_time3=$(time ( scp ./Plots/1000000bytes.txt epharra${host_id}@${i}:~/Documents 2>/dev/null 1>&2 ) 2>&1 )
		printf "\n1000000bytes\t%s" ${scp_time3} >> $outputFile

		#Add line numbers as a column. The reason we are redirecting the output to a new file, and not directly writing to outputFile, is because awk does not allow for us to read and write to the same file in one call. We must read from one file and write to a separate file.
		awk '{ print NR"\t", $0 }' $outputFile > $outputFileFinal
		
		#All the data we need is in the outputFileFinal file, remove outputFile		
		rm $outputFile
		
		#Create gnuplot scripts to graph results of each scp destination result
		#Write gnuplot scp script to file
		#The reason we are dynamically writing to gnuplot script here is because we don't want a hard-coded script with unchangable pi addresses. We want to be able to dynamically set Pi numbers. Since this scpTest.sh script knows the variables we will need for the .gp script, we will write to the .gp script here, using scpTest.sh's local variables.
		printf "set terminal png" >> ./Plots/gnuplotScpScript.gp
		printf "\nset output \"./Plots/gnuplotScpTo"%s".png\"" $i >> ./Plots/gnuplotScpScript.gp
		printf "\nset title \"Scp test results to "%s"\"" $i >> ./Plots/gnuplotScpScript.gp
		printf "\nshow title" >> ./Plots/gnuplotScpScript.gp
		printf "\nset xlabel \"file size\"" >> ./Plots/gnuplotScpScript.gp
		printf "\nset ylabel \"time in ms\"" >> ./Plots/gnuplotScpScript.gp
		printf "\nset boxwidth 0.5" >> ./Plots/gnuplotScpScript.gp
		printf "\nset style fill solid" >> ./Plots/gnuplotScpScript.gp
		printf "\nplot \"./"%s"\" using 1:3:xtic(2) with boxes notitle" $outputFileFinal >> ./Plots/gnuplotScpScript.gp
		printf "\nexit" >> ./Plots/gnuplotScpScript.gp
		
		#command for gnuplot to plot using .gp script we have just created
		gnuplot -p ./Plots/gnuplotScpScript.gp
		
		#Gnuplot has compiled and ran the .gp script for plotting. We can now remove the script in order to create the next .gp script for the next pi in the for loop.
		rm ./Plots/gnuplotScpScript.gp		
done
