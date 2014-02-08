"""
Each file that starts with test... in this directory is scanned for subclasses of unittest.TestCase or testLib.RestTestCase
"""

import unittest
import os
import testLib

class TestAddUser(testLib.RestTestCase):
    """Test adding users"""
    MAX_USERNAME_LENGTH = 128
    MAX_PASSWORD_LENGTH = 128

    def assertResponse(self, respData, count = 1, errCode = testLib.RestTestCase.SUCCESS):
        """
        Check that the response data dictionary matches the expected values
        """
        expected = { 'errCode' : errCode }
        if count is not None:
            expected['count']  = count
        self.assertDictEqual(expected, respData)

    def testUsernameEmpty(self):
        respData = self.makeRequest("/users/add", method="POST", data={'user':"", 'password':'password'})
        self.assertResponse(respData, 1, testLib.RestTestCase.ERR_BAD_USERNAME)

    def testUsernameTooLong(self):
        user1 = "a"*(TestAddUser.MAX_USERNAME_LENGTH+1)
        respData = self.makeRequest("/users/add", method="POST", data={'user':user1, 'password':'password'})
        self.assertResponse(respData, 1, testLib.RestTestCase.ERR_BAD_USERNAME)

    def passwordBlankOK(self):
        respData = self.makeRequest("/users/add", method="POST", data={'user':'user1', 'password':""})
        self.assertResponse(respData, 1, testLib.RestTestCase.SUCCESS)

    def passwordTooLong(self):
        password = "a"*(TestAddUser.MAX_PASSWORD_LENGTH+1)
        respData = self.makeRequest("/users/add", method="POST", data={'user':'user1', 'password':password})
        self.assertResponse(respData, 1, testLib.RestTestCase.ERR_BAD_PASSWORD)

    def userRegistered(self):
        respData = self.makeRequest("/users/add", method="POST", data={'user':'user1', 'password':'password'})
        self.assertResponse(respData, 1, testLib.RestTestCase.SUCCESS)
        respData = self.makeRequest("/users/add", method="POST", data={'user':'user1', 'password':'password'})
        self.assertResponse(respData, 1, testLib.RestTestCase.ERR_USER_EXISTS)

    def userCaseSensitive(self):
        respData = self.makeRequest("/users/add", method="POST", data={'user':'user1', 'password':'password'})
        self.assertResponse(respData, 1, testLib.RestTestCase.SUCCESS)
        respData = self.makeRequest("/users/add", method="POST", data={'user':'User1', 'password':'password'})
        self.assertResponse(respData, 1, testLib.RestTestCase.SUCCESS)

class TestLoginUser(testLib.RestTestCase):
    """Test logging in users"""
    def assertResponse(self, respData, count = 1, errCode = testLib.RestTestCase.SUCCESS):
        """
        Check that the response data dictionary matches the expected values
        """
        expected = { 'errCode' : errCode }
        if count is not None:
            expected['count']  = count
        self.assertDictEqual(expected, respData)

    def passwordCaseSensitive(self):
        respData = self.makeRequest("/users/add", method="POST", data={'user':'user1', 'password':'password'})
        self.assertResponse(respData, 1, testLib.RestTestCase.SUCCESS)
        respData = self.makeRequest("/users/login", method="POST", data={'user':'user1', 'password':'Password'})
        self.assertResponse(respData, 1, testLib.RestTestCase.ERR_BAD_CREDENTIALS)

    def newUserReject(self):
        respData = self.makeRequest("/users/login", method="POST", data={'user':'user1', 'password':'password'})
        self.assertResponse(respData, 1, testLib.RestTestCase.ERR_BAD_CREDENTIALS)
        
    def incorrectPassword(self):
        respData = self.makeRequest("/users/add", method="POST", data={'user':'user1', 'password':'password'})
        self.assertResponse(respData, 1, testLib.RestTestCase.SUCCESS)
        respData = self.makeRequest("/users/login", method="POST", data={'user':'user1', 'password':'hax0r'})
        self.assertResponse(respData, 1, testLib.RestTestCase.ERR_BAD_CREDENTIALS)

    def incrementCount(self):
        respData = self.makeRequest("/users/add", method="POST", data={'user':'user1', 'password':'password'})
        self.assertResponse(respData, 1, testLib.RestTestCase.SUCCESS)
        respData = self.makeRequest("/users/login", method="POST", data={'user':'user1', 'password':'password'})
        self.assertResponse(respData, 2, testLib.RestTestCase.SUCCESS)
        respData = self.makeRequest("/users/add", method="POST", data={'user':'user2', 'password':'password'})
        self.assertResponse(respData, 1, testLib.RestTestCase.SUCCESS)
        respData = self.makeRequest("/users/login", method="POST", data={'user':'user2', 'password':'password'})
        self.assertResponse(respData, 2, testLib.RestTestCase.SUCCESS)
        respData = self.makeRequest("/users/login", method="POST", data={'user':'user1', 'password':'password'})
        self.assertResponse(respData, 3, testLib.RestTestCase.SUCCESS)

    
