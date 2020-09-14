# ForwardNotifier
Forward your notifications from your iOS device to your PC/iOS device!


Hi! This tweak forwards your notifications to your PC (Windows, Mac or Linux!) or iOS device (tested on iOS 9-13 for the receiver part)

Up uptil now it only worked using SSH, but now, I am introducing the crossplatform server! A python script that creates a https server on your machine that listens to ForwardNotifier calls to display those notifications on your PC. (**Crossplatform server doesn't work on iOS devices, if you want to use an iOS device as a receiver you must use SSH. Instructions down below**).

**Read both methods (SSH and Crossplatform server) to decide which method you prefer to use. If one method does not work for you, you can try the other method**.

**If you are a beginner, I suggest you use the Crossplatform Server, it's much more user friendly. The SSH tutorial and Crossplatform tutorial are down below.**

# SSH Setup for the Receiver
## DO NOT USE THE SSH OPTION IF YOU STILL HAVE A VERSION THAT SUPPORTS IT. IT HAS A MAJOR BUG THAT COULD BE USED TO RUN TERMINAL COMMANDS ON YOUR COMPUTER
### MacOS

For MacOS you need a tool called “terminal-notifier”. It’s free and there are several tutorials on how to install it. Like this [one](https://brewinstall.org/install-terminal-notifier-on-mac-with-brew/)

To enable ssh on a Mac, follow this [tutorial](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwi6pbvMidzpAhURahQKHQYaBvsQFjACegQIDBAG&url=https%3A%2F%2Fosxdaily.com%2F2011%2F09%2F30%2Fremote-login-ssh-server-mac-os-x%2F&usg=AOvVaw3qUh4DI6uMFzS8KsyDa5Wm)

### Linux

For Linux you need a tool called “notify-send”. It comes preinstalled on several distros (most of Ubuntu flavors have it).
To enable ssh on Linux, install openssh-server

### Windows

For windows there’s a custom [tool](https://github.com/Greg0109/ForwardNotifier/tree/master/ForwardNotifier%20Client%20Tools/Windows%20SSH%20Client%20tool) (Although it is advised to use the Crossplatform server if using windows. It works better, is much more stable and it's more user friendly)

You also need OpenSSH server to be installed and working (**Please install openssh from [Powershell](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse#installing-openssh-with-powershell), in our testing it has proved to be more effective and it causes less errors**)

**Please, make sure the SSH service is up and running [SSH Service Configuration](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse#initial-configuration-of-ssh-server)**

**To use the tool, you need to download both .exe files and put them in Documents/ForwardNotifier, then, open the "SetEnvironmentVariable.exe" and it will set everything up.
Do not remove those .exe files, they are needed for it to work!
You might need a reboot upon installation.**

### iOS

On iOS you only need to have ForwardNotifier installed on both devices!

Notifications can be disabled when device is unlocked.

# Crossplatform Server Setup for the Receiver

To install the crossplatform server, you only need to install the provided Autoinstall packages. These installers will check and install all necessary dependencies for this program to work. **The Crossplatform server will autolaunch on every boot of the system**. Follow the instructions for each specific OS down below:

[MacOS](https://github.com/Greg0109/ForwardNotifier/blob/master/ForwardNotifier%20Client%20Tools/Crossplatform%20Server/Mac%20Autoinstall/ForwardNotifierInstaller.bash): Place the script anywhere you want on your Mac and launch it on terminal, like so "./ForwardNotifierInstaller" (Do not use sudo).

[Windows](https://github.com/Greg0109/ForwardNotifier/blob/master/ForwardNotifier%20Client%20Tools/Crossplatform%20Server/Windows%20Autoinstall/ForwardNotifierSetup.exe): Execute it as administrator as you would any other .exe file

[Linux](https://github.com/Greg0109/ForwardNotifier/blob/master/ForwardNotifier%20Client%20Tools/Crossplatform%20Server/Linux%20Autoinstall/ForwardNotifierInstaller.bash): Place the script anywhere you want on your Linux machine and launch it on terminal, like so "sudo ./ForwardNotifierInstaller" (please, use sudo).

If there's a "permissions error" while trying to use the MacOS or Linux tool, give the script permissions by using "chmod +x ForwardNotifierInstaller" in terminal on the same directory as the script.

# Where to find user and hostname

### In MacOS and Linux:

if you open terminal and type "users" you will get the users.
Also if you type "hostname", you will get the hostname.
Hostname needs a .local at the end.

**Password on all cases are the same as your main accounts on your devices**

### In Windows:
In Windows the username is the same as your username for your account.

IP can be found if you type "ipconfig" on cmd

**Password on all cases are the same as your main accounts on your devices**

### In iOS:
User is "root" or "mobile"
Hostname can be found if you open terminal, the first line where it usually says "*s-iphone"

You can also use your local ip instead of a hostname

**The default iOS password for SSH is "alpine" but you should definitely change your SSH password**

# ForwardNotifier sender setup
## Steps:

-Once the receivers have been setup, go to the tweak settings and fill out the SSH information there.

-**Make sure the user and hostname/ip are correct. Keep in mind that the crossplatform server only requires the hostname information**

-Enable the necessary switches

-**In order to activate the tweak, you need to activate the CC module and make sure its enabled. CC module can be found in the CC settings, if it's not there, you might need to install a third party CC module enabler like CCSupport**

# Additional Information

Since this tweak relies on a CC module to enable or disable it, it only supports iOS 11-13, but, I’ve tested the receiver from iOS 9-13 and it works without problems.

**Don't forget to insert your password!**

**If you prefer to use Key authentication, then make sure the key is working properly before using it. I've tested this tweak with keys using the .pem format**

# Troubleshooting

If the ssh fails, you will get a notification on your sender device with the title "ForwardNotifier Error". This will have the output of the error as a message. It will point you in the direction of where the error happened.

If you don't get that message and the notifications are still not displayed on the receiver, then something is wrong on the receiver end.


Other than that, there’s nothing more to it! Enjoy!

# Special thanks!

Thanks [u/LavamasterYT](https://www.reddit.com/u/LavamasterYT/?utm_source=share&utm_medium=ios_app&utm_name=iossmf) for making the SSH Windows Tool and the Windows Installation Package for the Crossplatform Server


Thanks to [u/tokilokit](https://www.reddit.com/u/tokilokit/?utm_source=share&utm_medium=ios_app&utm_name=iossmf) for the idea and development of the python script used for the Crossplatform server. His [GitHub](https://github.com/tokfrans03).
