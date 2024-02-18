#!/bin/bash

mkdir docker_install
cd docker_install
echo -n "" > docker_installer.log

#Check if the user is executing the file with sudo.
echo -n "Checking permission ... "
file_path=$(readlink -f "${BASH_SOURCE[0]}")
file_name=$(basename "$file_path")
ps_output=$(ps -ef | grep -v "grep" | grep "sudo ./$file_name")
if [ -z "$ps_output" ]; then
  echo "Please use sudo to execute $file_name" >> docker_installer.log
  echo -e "\033[31mFAIL\nError: Please use sudo to execute $file_name \033[0m"
  exit 1
else
  echo -e "\033[32mok\033[0m"
fi
echo "Permission ... ok" >> docker_installer.log

#Check if Python 3 exists.
echo -n "Checking python3 ... "
python_version=$(python3 --version 2>> docker_installer.log)
if [ -z "$python_version" ]; then
  echo -e "\033[31mFAIL\nError: Please check docker_installer.log to understand the cause of the issue.\033[0m"
  exit 1
else
  echo -e "\033[32mok\033[0m"
fi
echo "Python3 ... ok" >> docker_installer.log

#Download script.
echo -n "Downloading script ... "
curl -fsSL get.docker.com -o get-docker.sh >> docker_installer.log 2> error.log
read is_error < error.log
if [ -z "$is_error" ]; then
  echo -e "\033[32mok\033[0m"
  echo "Download script ... ok" >> docker_installer.log
else
  cat error.log >> docker_installer.log
  rm -f error.log
  echo -e "\033[31mFAIL\nError: Please check docker_installer.log to understand the cause of the issue.\033[0m"
fi

sleep 2

sudo sh get-docker.sh
sudo pip install docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl restart docker

#Cleaning up
echo -n "Cleaning up ... "
cd ..
rm -fr ./docker_install
echo -e "\033[32mok\033[0m"