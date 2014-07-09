#!/usr/bin/env python

import web
import json
from urllib import quote, unquote

urls = ('(.*)', 'urlhandler')


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
        return "OK"

if __name__ == '__main__':
    app = web.application(urls, globals())
    app.run()
