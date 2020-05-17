#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
# import platform
import subprocess
port = 8000


def sendnotif(Title, Message, OS):  # send os with the request since it's known by the sender
    # system = platform.system()
    if OS == "Windows":
        subprocess.call(["ForwardNotifierReceiver", "-Title",
                         Title, "-message", Message])
    elif OS == "Linux":
        subprocess.call(
            ["notify-send", "-i", "applications-development", Title, Message])
    elif OS == "MacOS":
        subprocess.call(["/usr/local/bin/terminal-notifier",
                         "-sound", "pop", "-title", Title, "-message", Message])


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
            body = post_data.decode('utf-8')
            print("Body:\n" + post_data.decode('utf-8'), "\n")
            if checkbody(body)[0] == True:  # all good

                body = json.loads(body)
                sendnotif(body["Title"], body["Message"], body["OS"])  # sends the body

                self.send_res("Sent!")

            else:  # Body is wrong

                print(checkbody(body)[1])  # send the error
                self.send_res(checkbody(body)[1], Success=False)

        else:
            self.send_res(
                "POST request for {} . Please send a body".format(self.path), Success=False)


def run(server_class=HTTPServer, handler_class=S, port=port):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print('Starting httpd on port', port, '...')
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
