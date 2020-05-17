# A Crossplatform recever

## What is this?

This is a Crossplatform recever written in python that dosen't use ssh for notification sending but instead http with POST requests.

This can also be used by anything else by anyone else on the network for other DIY projects.

## What needs to be implemented?
### Sender
A switch that changes between ssh and http,
this switch changes the command from 

`/usr/bin/sshpass -p <password> ssh StrictHostKeyChecking=no <user>@<ip> <os specific command>`

to

`curl <ip>:<selected port> -d '{"Title": "<title>", "Message": "<Message>", "OS": "<Selected OS>"}'`

### Recever

a autostarting service that runs `python3 BackendApi.py [port]`

launchctl on mac,
systemctl on linux,
services on windows

# Example
## curl
`curl localhost:8000 -d '{"Title": "This is the title", "Message": "This is the message", "OS": "Windows"}'`

## JSON

    {
        "Title": "This is the title",
        "Message": "This is the message",
        "OS": "Windows"
    }