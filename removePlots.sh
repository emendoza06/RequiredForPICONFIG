#!/bin/bash

cd ~/RequiredForPICONFIG
cd Plots
echo "Deleting files $(find ~/RequiredForPICONFIG/Plots -type f ! -name '*bytes.txt')"
find ~/RequiredForPICONFIG/Plots -type f ! -name '*bytes.txt' -delete
