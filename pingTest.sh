#!/bin/bash 

#Ensure that we are in the correct directory
cd ~/RequiredForPICONFIG
#Get the first column of routing table entries, which are the Destination IP addresses
#awk $1 gets the first argument of every line. Then, we discard the address 10.0.0.0 because this is our default and we don't plot this.
entries=$(netstat -rn | awk '/10.0.0/ {print}'| awk '! /10.0.0.0/ {print $1}')

#If the user has defined a specific ping count they'd like, then this variable will be located in the pi's config file. Locate it and store in ping_count_custom.
ping_count_custom=$(awk 'NR==1 {print; exit}' pi*config.txt)
#echo $ping_count_custom

#Index for for loop
INDEX=1

#loop through each line in routing table (Lines are saved in variable called entries)
for i in $entries;

#For each line in routing table,
do
		
		#Create a string name for the output File. Store the string into variable outputFile	
		outputFile="./Plots/pingOutput${i}.dat"
		echo "${outputFile} ...Entering data..."
		#Create the outputfile
		touch $outputFile	

		#Create a string name for the final output file. Store the string into variable outputFileFinal
		outputFileFinal="./Plots/pingOutputFinal${i}.dat"
		
		#perform ping
		#ping_count_custom is an integer, where user defined the count
		#i is the current pi we are pinging. We are using a for loop to loop through each pi address
		#Use a series of pipes and awks to find only the rtt number, then redirect that number into outputFileFinal
		ping -c $ping_count_custom $i | awk '/time/ && /icmp_seq/ {print}' | awk '{print $7}' | awk -F= '{print $2}' > $outputFileFinal

		#Find avg_rtt and store in a variable
		avg_rtt=$(awk '{sum+=$1} END {print sum/NR}' $outputFileFinal)


		#Add ping count number as a column, redirect to outputFile. The reason we are redirecting and not writing directly to outputFileFinal, is because awk does not allow for us to read and write to the same file in one call. We must read from one file and write to a separate file. 		
		awk '{ print NR"\t", $0 }' $outputFileFinal > $outputFile
			
		#add avg_rtt to files
		awk -v avgrtt=$avg_rtt '{print $0"\t " avgrtt}' $outputFile > $outputFileFinal
		
		#All the data we need is in the outputFilFinal file, remove outputFile.
		rm $outputFile
		

		#Create gnuplot scripts to graph results of each ping destination result
		#Write gnuplot ping script to .gp file.
	       #The reason we are dynamically writing to gnuplot scripts here is because we don't want a hard-coded script with unchangable pi addresses. We want to be able to dynamically set Pi numbers and ping numbers. Since this pingTest.sh script knows the variables we will need for the .gp script, we will write to the .gp script here, using pingTest.sh's local variables.
		printf "set terminal png" >> ./Plots/gnuplotPingScript.gp
		printf "\nset output \"./Plots/gnuplotPingTo"%s".png\"" $i >> ./Plots/gnuplotPingScript.gp
		printf "\nset title \"Ping test results to "%s"\"" $i >> ./Plots/gnuplotPingScript.gp
		printf "\nshow title" >> ./Plots/gnuplotPingScript.gp
		printf "\nset xlabel \"ping count\"" >> ./Plots/gnuplotPingScript.gp
		printf "\nset ylabel \"time in ms\"" >> ./Plots/gnuplotPingScript.gp
		printf "\nplot \"./"%s"\" using 1:2 w lp title \"rtt of each ping\",\\" $outputFileFinal >> ./Plots/gnuplotPingScript.gp
		printf "\n\t\"./"%s"\" using 1:3 w lp title \"avg rtt\"" $outputFileFinal >> ./Plots/gnuplotPingScript.gp
		printf "\nexit" >> ./Plots/gnuplotPingScript.gp
		
		#command for gnuplot to plot using .gp script we have just created.
		gnuplot -p ./Plots/gnuplotPingScript.gp
		
		#Gnuplot has compiled and ran the .gp script for plotting. We can now remove the script in order to create the next .gp script for the next pi in the for loop. 
		rm ./Plots/gnuplotPingScript.gp		
done
