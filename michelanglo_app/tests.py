import unittest

from pyramid import testing


class ViewTests(unittest.TestCase):
    def setUp(self):
        self.config = testing.setUp()

    def tearDown(self):
        testing.tearDown()

    def test_my_view(self):
        from michelanglo_app.views.views import my_view
        request = testing.DummyRequest()
        info = my_view(request)
        self.assertEqual(info['project'], 'michelanglo_app')


class FunctionalTests(unittest.TestCase):
    def setUp(self):
        from michelanglo_app import main
        app = main({})
        from webtest import TestApp
        self.testapp = TestApp(app)

    def test_root(self):
        res = self.testapp.get('/', status=200)
        self.assertTrue(b'Pyramid' in res.body)



import requests

def ajacenteanTests(url='http://brc10.well.ox.ac.uk:8088/'):
    #not a unit test as the server need to be running.

    r = requests.post(url, headers={"content-type": "text"})


