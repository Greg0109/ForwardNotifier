#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import platform
import subprocess
import base64
import requests
import re
import time

if platform.system() == "Windows":
    from PIL import Image  # convert to ico
    from win10toast import ToastNotifier
    toaster = ToastNotifier()

port = 8000

version = "1.0.2"
iconpath = {
    "Windows": "/temp/ForwardNotifierIcon",
    "Linux": "/tmp/ForwardNotifierIcon",
    "Darwin": "/tmp/ForwardNotifierIcon", # macos
    "MacOS": "/tmp/ForwardNotifierIcon"
}

tries = 0
def checkforupadate():
    global tries
    try:
        url = "https://raw.githubusercontent.com/Greg0109/ForwardNotifier/master/ForwardNotifier%20Client%20Tools/Crossplatform%20Server/ForwardNotifierServer.py"
        r = requests.get(url).text
        m = re.search(r'version = .+', r)
        ver = m.group(0).split("=")[1].replace('"', "").replace(" ", "")
        if ver != version:
            sendnotif("Update availabe!",
                      "Run the install script again to update ForwardNotifier", platform.system())
    except requests.exceptions.ConnectionError:
        if tries < 5:
            sendnotif("Couldn't access github", "Trying again in 5 seconds.", platform.system())
            time.sleep(5)
            tries += 1
            checkforupadate()
        else:
            sendnotif("Couldn't access github", "Please check your internet connection or contact the developer.", platform.system())


# send os with the request since it's known by the sender
def sendnotif(Title, Message, OS, icon=None):
    # system = platform.system()
    try:
        try:  # Try to decode
            Title = base64.b64decode(Title.encode("utf-8")).decode("utf-8")
        except:
            print("Title is not base64")
        try:  # Try to decode
            Message = base64.b64decode(Message.encode("utf-8")).decode("utf-8")
        except:
            print("Message is not base64")
        if icon:
            print("Theres an icon!")
            icon = base64.decodebytes(icon.encode("utf-8"))
            open(iconpath[OS], "wb").write(icon) # send img to correct path

        print("Sending notification:")
        print("Title:", Title)
        print("Message:", Message)

        if OS == "Windows":
            if icon:
                # try:  # Try to decode
                filename = iconpath[OS]
                img = Image.open(filename)
                img.save(iconpath[OS] + '.ico', format = 'ICO')
                toaster.show_toast(Title,
                                    Message,
                                    icon_path=iconpath[OS] + ".ico",
                                    duration=5,
                                    threaded=True)
                # except:  # icon not base64 aka ignore
                #     toaster.show_toast(Title,
                #                        Message,
                #                        duration=5,
                #                        threaded=True)
            else:
                toaster.show_toast(Title,
                                Message,
                                duration=5,
                                threaded=True)
        elif OS == "Linux":
            if icon:
                subprocess.call(
                    ["notify-send", "-i", iconpath[OS], Title, Message])
            else:
                subprocess.call(
                    ["notify-send", "-i", "applications-development", Title, Message])
        elif OS == "Darwin" or OS == "MacOS": # macos
            if icon:
                subprocess.call(["/usr/local/bin/terminal-notifier",
                                "-sound", "pop", "-appIcon", iconpath[OS], "-title", Title, "-message", Message])
            else:
                subprocess.call(["/usr/local/bin/terminal-notifier",
                    "-sound", "pop", "-title", Title, "-message", Message])
    except:
        sendnotif("Error", "unknown error while sending notification", platform.system())


def checkbody(body):  # checking the body for a post request, wont be a problem since we send it
    try:
        try:
            body = json.loads(body)
        except:
            return [False, "Unable to parse json"]

        if "Title" not in body:
            return [False, "No 'Title' in body"]

        if "Message" not in body:
            return [False, "No 'Message' in body"]

        if "OS" not in body:
            return [False, "No 'OS' in body"]

        if "img" in body:
            try:
                base64.decodebytes(body["img"].encode("utf-8"))
            except:
                return [False, "Img not base64"]


        return [True]
    except:
        return [False, "unknown error"]


class S(BaseHTTPRequestHandler):
    def send_res(self, args, code=200, Success=True):

        self.send_response(code)
        self.send_header('Content-type', 'text/html')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        out = {
            "Success": Success,
            "value": args
        }
        print("Sending: ", json.dumps(out).encode('utf-8'))
        self.wfile.write(json.dumps(out).encode('utf-8'))

    def do_GET(self):

        print("\nPath:", self.path)
        print(self.headers)

        self.send_res(
            "Send a Post with a title and a message in a json format")

    def do_POST(self):
        # <--- Gets the size of data
        content_length = int(self.headers['Content-Length'])
        # <--- Gets the data itself
        post_data = self.rfile.read(content_length)
        # print(json.loads(post_data.decode('utf-8')))
        print("\nPath:", str(self.path),
              "\nHeaders:\n" + str(self.headers))
        print(content_length)
        if content_length > 0:
            try:
                body = post_data.decode('utf-8')
                print("Body:\n" + post_data.decode('utf-8'), "\n")
            except UnicodeEncodeError as e:
                print("ForwardNotifierReciver Error:", e)
                sendnotif("ForwardNotifierReciver Error:",
                          "invalid characters", platform.system())
            if checkbody(body)[0] == True:  # all good

                body = json.loads(body)
                if "img" in  body:
                    sendnotif(body["Title"], body["Message"],
                              body["OS"], body["img"])  # sends the body
                else:
                    sendnotif(body["Title"], body["Message"],
                              body["OS"])  # sends the body

                self.send_res("Sent!")

            else:  # Body is wrong

                print(checkbody(body)[1])  # send the error
                self.send_res(checkbody(body)[1], Success=False, code=400)

        else:
            self.send_res(
                "POST request for {} . Please send a body".format(self.path), Success=False)


def run(server_class=HTTPServer, handler_class=S, port=port):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print('Starting httpd on port', port, '...')
    checkforupadate()
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    print('\nStopping httpd...')


if __name__ == '__main__':
    from sys import argv

    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()
