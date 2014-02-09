require File.expand_path("../../../app/controllers/client_controller", __FILE__)
require 'test_helper'

class UserDataTest < ActiveSupport::TestCase
	test "username should not be blank" do
		assert_equal(UsersModel.add("", "secret"),
			UsersModel::ERR_BAD_USERNAME,
			"username should not be blank")
    end
	test "username should not be too long" do
		name = "a"*UsersModel::MAX_USERNAME_LENGTH
		assert_equal(UsersModel.add(name, "secret"), 1,
			"username of length=MAX_USERNAME_LENGTH is OK")
		assert_equal(UsersModel.add(name+"a", "secret"),
			UsersModel::ERR_BAD_USERNAME,
			"username of length>MAX_USERNAME_LENGTH not OK")
	end
	test "password can be blank" do
		assert_equal(UsersModel.add("kevin", ""), 1,
			"password can be blank")
	end
	test "password should not be too long" do
		password = "a"*UsersModel::MAX_PASSWORD_LENGTH
		assert_equal(UsersModel.add("kevin", password), 1,
			"password of length=MAX_PASSWORD_LENGTH is OK")
		assert_equal(UsersModel.add("steve", password+"a"),
			UsersModel::ERR_BAD_PASSWORD,
			"password of length>MAX_PASSWORD_LENGTH not OK")
	end
	test "should not add an already registered user" do
		assert_equal(UsersModel.add("kevin", "secret"), 1,
			"added new user")
		assert_equal(UsersModel.add("kevin", "secret"),
			UsersModel::ERR_USER_EXISTS,
			"should not add an already added user")
	end
	test "usernames are case-sensitive" do
		assert_equal(UsersModel.add("kevin", "secret"), 1,
			"added new user")
		assert_equal(UsersModel.add("Kevin", "secret"), 1,
			"usernames are case-sensitive")
		assert_equal(UsersModel.login("keviN", "secret"),
			UsersModel::ERR_BAD_CREDENTIALS,
			"usernames are case-sensitive")
	end
	test "passwords are case-sensitive" do
		assert_equal(UsersModel.add("kevin", "secret"), 1,
			"added new user")
		assert_equal(UsersModel.login("kevin", "Secret"),
			UsersModel::ERR_BAD_CREDENTIALS,
			"passwords are case-sensitive")
	end
	test "same password doesn't count as being a reg. user" do
		assert_equal(UsersModel.login("ghost", "secret"),
			UsersModel::ERR_BAD_CREDENTIALS,
			"new user with same password as a reg. user cannot login")
	end
	test "incorrect password cannot login" do
		assert_equal(UsersModel.add("kevin", "secret"), 1,
			"added new user")
		assert_equal(UsersModel.login("kevin", "Secret"),
			UsersModel::ERR_BAD_CREDENTIALS,
			"incorrect password")
	end
	test "increment count on correct username/password" do
		assert_equal(UsersModel.add("kevin", "secret"), 1,
			"added new user 1")
		assert_equal(UsersModel.login("kevin", "secret"), 2,
			"user 1 logged in")
		assert_equal(UsersModel.add("calvin", "secret"), 1,
			"added new user 2")
		assert_equal(UsersModel.login("calvin", "secret"), 2,
			"user 2 logged in")
		assert_equal(UsersModel.login("kevin", "secret"), 3,
			"user 1 logged in")
	end
end
