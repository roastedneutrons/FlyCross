#!/usr/bin/env python
from google.appengine.ext import webapp
from google.appengine.ext.webapp import util


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


def main():
    application = webapp.WSGIApplication([('/', MainHandler),
                                         ('/singlecross', singlecross),
                                         ('/multicross', multicross)],
                                         debug=True)
    util.run_wsgi_app(application)


if __name__ == '__main__':
    main()
