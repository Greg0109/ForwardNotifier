#!/bin/bash
checkroot=$(whoami)
if [[ $checkroot != "root" ]]; then
	echo "This script needs to be executed as root"
	exit
fi
checkapt=$(which apt-get)
checkpacman=$(which pacman)
if [[ ! -z "$checkapt" ]]; then
	manager="apt-get install"
	echo "You are using apt-get"
elif [[ ! -z "$checkpacman" ]]; then
	manager="pacman -S"
	echo "You are using pacman"
else
	echo "Package Manager not recognized"
	exit
fi
user=$(awk -F'[/:]' '{if ($3 >= 1000 && $3 != 65534) print $1}' /etc/passwd)
echo "Select your user account (type the number):"
iter=0
for username in "${user[@]}"
do
	echo "$iter: $username"
	iter=$(( iter + 1 ))
done
read answer
user="${user[$answer]}"
echo "user is $user"

echo "Checking python3 installation...."
check=$( which python3 )
if [[ -z "$check" ]]; then
    sudo $manager python3
else
    echo "Python3 is installed"
fi

echo "Installing python modules..."
checkmodules=$(pip3 freeze)
checkrequests=$(echo $checkmodules | grep -i requests)
if [[ -z $checkrequests ]]; then
	pip3 install requests
fi

echo "Checking python script installation....."
serverinstalled=$( ls /usr/bin | grep ForwardNotifierServer)
if [[ -z $serverinstalled ]]; then
	echo "Installing the python script...."
	wget https://raw.githubusercontent.com/Greg0109/ForwardNotifier/master/ForwardNotifier%20Client%20Tools/Crossplatform%20Server/ForwardNotifierServer.py
	if [[ $? -ne 0 ]]; then
		echo "Something went wrong with the download, please make sure your internet connection is on"
		exit
	fi
	sudo mv ForwardNotifierServer.py /usr/bin/
	echo "Python script installed"
else
	echo "Python script is installed, updating....."
	sudo rm /usr/bin/ForwardNotifierServer.py
	wget https://raw.githubusercontent.com/Greg0109/ForwardNotifier/master/ForwardNotifier%20Client%20Tools/Crossplatform%20Server/ForwardNotifierServer.py
	if [[ $? -ne 0 ]]; then
		echo "Something went wrong with the download, please make sure your internet connection is on"
		exit
	fi
	sudo mv ForwardNotifierServer.py /usr/bin/
	echo "Python script updated"
fi

echo "Checking service installation..."
service=$(ls /etc/systemd/system | grep ForwardNotifierServer)
if [[ -z $service ]]; then
	echo "Setting up the service..."
sudo cat <<EOF >> /etc/systemd/system/ForwardNotifierServer.service
[Unit]
Description=ForwardNotifierServer
Requires=network-online.target

[Service]
User=$user
ExecStart=$check /usr/bin/ForwardNotifierServer.py
Type=simple
RemainAfterExit=yes
Environment="DISPLAY=:0" "XAUTHORITY=/home/$user/.Xauthority"

[Install]
WantedBy=multi-user.target
EOF
	sudo systemctl daemon-reload
	sudo systemctl enable ForwardNotifierServer.service
	sudo systemctl start ForwardNotifierServer.service
	echo "Service set up, installation done!"
else
	sudo systemctl daemon-reload
	sudo systemctl enable ForwardNotifierServer.service
	sudo systemctl start ForwardNotifierServer.service
	echo "Service installed"
fi
echo "Checking notify-send installation...."
notifier=$(which notify-send)
if [[ -z "$notifier" ]]; then
	sudo $manager libnotify-bin #sudo pacman -S libnotify
else
	echo "Notify-send installed"
fi

host=$(hostname)
echo ""
echo "----------------------------"
echo ""
echo "This is your hostname: $host.local"
echo "You can also use your PC's ip address"
echo "Enjoy!"
