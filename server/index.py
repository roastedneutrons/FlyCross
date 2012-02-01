#!/usr/bin/env python

import cgi
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util
from google.appengine.api import mail
from django.utils import simplejson as json

class MainHandler(webapp.RequestHandler):
    def get(self):
        self.response.out.write("""<a href=\"/singlecross/index.html\">Single Cross</a><br/>
                <a href=\"/multicross/index.html\">Multi stepped Crosses</a>""")

class singlecross(webapp.RequestHandler):
	def get(self):
		self.redirect("/singlecross/index.html")

class multicross(webapp.RequestHandler):
	def get(self):
		self.redirect("/multicross/index.html")

class feedback(webapp.RequestHandler):
	def post(self):
		jsonData=json.loads(cgi.escape(self.request.body))
		mail.send_mail(sender="<sudhirpalliyil@gmail.com>",
				to="Sudhir P<sudhirpalliyil@gmail.com>",
				subject=jsonData['utilName']+" feedback | "+jsonData["title"] ,
				body="From : "+jsonData["email"]+"\n\n"+jsonData["body"])
		self.response.out.write("ok")

def main():
    application = webapp.WSGIApplication([('/', MainHandler),
                                         ('/singlecross', singlecross),
                                         ('/multicross', multicross),
                                         ('/feedback', feedback)],
                                         debug=True)
    util.run_wsgi_app(application)


if __name__ == '__main__':
    main()
