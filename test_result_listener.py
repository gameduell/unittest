#!/usr/bin/env python

import sys
import web
import json
from urllib import quote, unquote

urls = ('(.*)', 'urlhandler')

app = web.application(urls, globals())

def rawRequest(env):
    raw_post_data = env['wsgi.input'].read(int(env['CONTENT_LENGTH']))
    post_data = None
    post_data = unquote(raw_post_data)

    return post_data[len("data="):]


class urlhandler:
    def OPTIONS(self, url):
        web.header('Access-Control-Allow-Origin',      '*')
        web.header('Access-Control-Allow-Credentials', 'true')
        web.header('Access-Control-Allow-Headers',
                   'origin, content-type, ' +
                   'accept, Access-Control-Allow-Credentials, ' +
                   'Access-Control-Allow-Origin')
        return ""

    def POST(self, url):
        web.header('Access-Control-Allow-Origin',      '*')
        web.header('Access-Control-Allow-Credentials', 'true')
        s = rawRequest(web.ctx.env)
        print "\n%s\n%s\n%s\n" % ('-'*60, s, '-'*60)
        app.stop()
        return "OK"

if __name__ == '__main__':
    import os
    import subprocess

    os.chdir("test")
    p = subprocess.Popen(["haxelib", 'run', "lime", "test", "html5"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    os.chdir("..")

    app.run()

    output = subprocess.check_output(["ps", "aux"])
    server_line = [line for line in output.split("\n") if "http-server" in line]
    if len(server_line) != 0:
        import re
        server_line_split = re.split('\\s+', server_line[0])
        
        server_pid = server_line_split[1]
        subprocess.check_output(["kill", server_pid])
