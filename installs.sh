#!/bin/bash

#OpenSSH suite consists of the following tools: ssh, scp 
sudo apt install openssh-server -y
#Opens port to allow for ssh
sudo ufw allow ssh
#Text editor program
sudo apt-get install vim -y
#Graph visualization software that represents graphs and networks. For drawing graphs specified in DOT language scripts having the file name extension 'gv'
sudo apt-get install graphviz -y
#Java Runtime Environment
sudo apt install default-jre -y
#Java Development Kit
sudo apt-get install openjdk-8-jdk -y
#Install git
sudo apt-get install git

