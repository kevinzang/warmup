require File.expand_path("../../../app/controllers/UM", __FILE__)
require "test/unit"

class TestUM < Test::Unit::TestCase
	def setup()
		UM.TESTAPI_resetFixture()
	end
	def test_1()
		# username should not be blank
		assert_equal(UM.add("", "secret"),
			UM::ERR_BAD_USERNAME,
			"username should not be blank")
    end
	def test_2()
	    # username should not be too long
		name = "a"*UM::MAX_USERNAME_LENGTH
		assert_equal(UM.add(name, "secret"), 1,
			"username of length=MAX_USERNAME_LENGTH is OK")
		assert_equal(UM.add(name+"a", "secret"),
			UM::ERR_BAD_USERNAME,
			"username of length>MAX_USERNAME_LENGTH not OK")
	end
	def test_3()
		# password can be blank
		assert_equal(UM.add("kevin", ""), 1,
			"password can be blank")
	end
	def test_4()
		# password should not be too long
		password = "a"*UM::MAX_PASSWORD_LENGTH
		assert_equal(UM.add("kevin", password), 1,
			"password of length=MAX_PASSWORD_LENGTH is OK")
		assert_equal(UM.add("steve", password+"a"),
			UM::ERR_BAD_PASSWORD,
			"password of length>MAX_PASSWORD_LENGTH not OK")
	end
	def test_5()
		# should not add an already registered user
		assert_equal(UM.add("kevin", "secret"), 1,
			"added new user")
		assert_equal(UM.add("kevin", "secret"),
			UM::ERR_USER_EXISTS,
			"should not add an already added user")
	end
	def test_6()
		# usernames are case-sensitive
		assert_equal(UM.add("kevin", "secret"), 1,
			"added new user")
		assert_equal(UM.add("Kevin", "secret"), 1,
			"usernames are case-sensitive")
		assert_equal(UM.login("keviN", "secret"),
			UM::ERR_BAD_CREDENTIALS,
			"usernames are case-sensitive")
	end
	def test_7()
		# passwords are case-sensitive
		assert_equal(UM.add("kevin", "secret"), 1,
			"added new user")
		assert_equal(UM.login("kevin", "Secret"),
			UM::ERR_BAD_CREDENTIALS,
			"passwords are case-sensitive")
	end
	def test_8()
		# same password doesn't count as being a reg. user
		assert_equal(UM.login("ghost", "secret"),
			UM::ERR_BAD_CREDENTIALS,
			"new user with same password as a reg. user cannot login")
	end
	def test_9()
		# incorrect password cannot login
		assert_equal(UM.add("kevin", "secret"), 1,
			"added new user")
		assert_equal(UM.login("kevin", "Secret"),
			UM::ERR_BAD_CREDENTIALS,
			"incorrect password")
	end
	def test_10()
		# increment count on correct username/password
		assert_equal(UM.add("kevin", "secret"), 1,
			"added new user 1")
		assert_equal(UM.login("kevin", "secret"), 2,
			"user 1 logged in")
		assert_equal(UM.add("calvin", "secret"), 1,
			"added new user 2")
		assert_equal(UM.login("calvin", "secret"), 2,
			"user 2 logged in")
		assert_equal(UM.login("kevin", "secret"), 3,
			"user 1 logged in")
	end
end