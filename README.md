# ForwardNotifier
Forward your notifications from your iOS device to your PC/iOS device!


Hi! This tweak forwards your notifications to your PC (Windows, Mac or Linux!) or iOS device (tested on iOS 9-13 for the receiver part)

It works using SSH, so it can works locally for now (although I will add more features in the future for it to work via open ports and use other services like PushOver).

# IMPORTANT INFORMATION

For MacOS you need a tool called “terminal-notifier”. It’s free and there are several tutorials on how to install it. Like this one

To enable ssh on a Mac, follow this tutorial

——

For Linux you need a tool called “notify-send”. It comes preinstalled on several distros (most of Ubuntu flavors have it). 
To enable ssh on Linux, install openssh-server

——

For windows there’s a custom tool made by u/LavamasterYT (thank you so much!) that is needed in order to work. 

You also need OpenSSH server to be installed and working (**Please install openssh from Powershell, in our testing it has proved to be more effective and it causes less errors**)

[Windows Tool](https://github.com/Greg0109/ForwardNotifier/tree/master/Windows%20Client)

**To use the tool, you need to download both .exe files and put them in Documents/ForwardNotifier, then, open the "SetEnvironmentVariable.exe" and it will set everything up.
Do not remove those .exe files, they are needed for it to work!
You might need a reboot upon installation.**

——

On iOS you only need to have ForwardNotifier installed on both devices!

Notifications can be disabled when device is unlocked.

# Where to find user and hostname

In MacOS and Linux:

if you open terminal and type "users" you will get the users.
Also if you type "hostname", you will get the hostname.
Hostname needs a .local at the end.

iOS:
User is "root" or "mobile"
Hostname can be found if you open terminal, the first line where it usually says "*s-iphone"

You can also use your local ip instead of a hostname

# ForwardNotifier sender setup
Steps:

-Once the receivers have been setup, go to the tweak settings and fill out the SSH information there. 

-**Make sure the user and hostname/ip are correct.**

-Enable the necessary switches

-**In order to activate the tweak, you need to activate the CC module and make sure its enabled**

# Additional Information

Since this tweak relies on a CC module to enable or disable it, it only supports iOS 11-13, but, I’ve tested the receiver from iOS 9-13 and it works without problems.

**Don't forget to insert your password!**

# Troubleshooting

If the ssh fails, you will get a notification on your sender device with the title "ForwardNotifier Error". This will have the output of the error as a message. It will point you in the direction of where the error happened.

If you don't get that message and the notifications are still not displayed on the receiver, then something is wrong on the receiver end.


Other than that, there’s nothing more to it! Enjoy!
