import cgi,re

from django.utils import simplejson as json

from Flies import *
import dummyFlies

from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app


class Analyzer(webapp.RequestHandler):
	def post(self):
		jsonDataFromCS=json.loads(cgi.escape(self.request.body))
		constraints=jsonDataFromCS['constraints']
		balancers=jsonDataFromCS['balancers']
		markers=jsonDataFromCS['markers']
		updateLists(constraintsList=constraints,balancersList=balancers,markersList=markers)
		father=Fly(jsonDataFromCS['father'])
		mother=Fly(jsonDataFromCS['mother'])
		childStr=jsonDataFromCS['child']
		if childStr=="":
			child=None
		else:
			child=Fly(childStr)

		punnettSqr=json.dumps(punnettDict(father,mother,child))
		self.response.out.write(punnettSqr)

class Echo(webapp.RequestHandler):
	def get(self):
		self.response.out.write("Echo, cho, ho, o")
	def post(self):
		self.response.out.write(self.request.body)


application = webapp.WSGIApplication([('/api/singlecross/echo', Echo),
                                      ('/api/singlecross/analyze', Analyzer)],
                                     debug=True)

def main():
	run_wsgi_app(application)

if __name__ == "__main__":
	main()
