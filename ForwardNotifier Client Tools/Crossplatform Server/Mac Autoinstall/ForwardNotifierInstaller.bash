#!/bin/bash
echo "Checking for brew installation..."

brewinstallation=$(ls /usr/local/bin | grep brew)
if [[ -z $brewinstallation ]]; then
	echo "Installing brew....."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
	echo "Brew is already installed"
fi

echo "Installing wget..."
brew install wget

echo "Checking for terminal-notifier installation..."
terminalnotifierinstallation=$(ls /usr/local/bin | grep terminal-notifier)
if [[ -z $terminalnotifierinstallation ]]; then
	echo "Installing terminal-notifier....."
	brew install terminal-notifier
else
	echo "Terminal-notifier already installed"
fi

echo "Checking python3 installation...."
check=$( which python3 )
if [[ -z "$check" ]]; then
    brew install python3
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
serverinstalled=$( ls ~/ | grep ForwardNotifierServer)
if [[ -z $serverinstalled ]]; then
	echo "Installing the python script...."
	wget https://raw.githubusercontent.com/Greg0109/ForwardNotifier/master/ForwardNotifier%20Client%20Tools/Crossplatform%20Server/ForwardNotifierServer.py
	if [[ $? -ne 0 ]]; then
		echo "Something went wrong with the download, please make sure your internet connection is on"
		exit
	fi
	sudo mv ForwardNotifierServer.py ~/
	serverpath=$(echo ~/ForwardNotifierServer.py)
sudo cat <<EOF >> ~/Library/LaunchAgents/ForwardNotifierServer.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>ForwardNotifierServer</string>
    <key>ProgramArguments</key>
    <array>
        <string>$check</string>
        <string>$serverpath</string>
    </array>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF
	sudo chown root:wheel ~/Library/LaunchAgents/ForwardNotifierServer.plist
	sudo chmod 644 ~/Library/LaunchAgents/ForwardNotifierServer.plist
	sudo launchctl load ~/Library/LaunchAgents/ForwardNotifierServer.plist
	sudo launchctl start ~/Library/LaunchAgents/ForwardNotifierServer.plist
else

	echo "Python script is installed, updating....."
	sudo rm ~/ForwardNotifierServer.py
	wget https://raw.githubusercontent.com/Greg0109/ForwardNotifier/master/ForwardNotifier%20Client%20Tools/Crossplatform%20Server/ForwardNotifierServer.py
	if [[ $? -ne 0 ]]; then
		echo "Something went wrong with the download, please make sure your internet connection is on"
		exit
	fi
	sudo mv ForwardNotifierServer.py ~/
	sudo launchctl stop ~/Library/LaunchAgents/ForwardNotifierServer.plist
	sudo launchctl load ~/Library/LaunchAgents/ForwardNotifierServer.plist
	sudo launchctl start ~/Library/LaunchAgents/ForwardNotifierServer.plist
	echo "Python script updated"
fi


host=$(hostname)
echo ""
echo "----------------------------"
echo ""
echo "This is your hostname: $host"
echo "You can also use your PC's ip address"
echo "Enjoy!"

echo "Reboot is required, press any key to reboot, or type \"cancel\" to reboot later:"
read reboot
if [[ $reboot != "cancel" ]]; then
    sudo reboot
fi
