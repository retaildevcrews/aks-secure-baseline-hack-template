#!/bin/sh

# add environment specific commands here
echo $HOME >> status
echo $USER >> status
pwd >> status
whoami >> status

# upgrade packages - faster startup here than in Dockerfile
sudo apt-get update
sudo apt-get upgrade -y
