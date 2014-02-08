require 'test_helper'
require File.expand_path('../../../app/controllers/client_controller', __FILE__)

class UserDataTest < ActiveSupport::TestCase
	test "user should not be blank" do
		assert UsersModel::ERR_BAD_USERNAME ==
		UsersModel.add("", "secret")
	end
	test "user should not be too long" do
		name = "a"*UsersModel::MAX_USERNAME_LENGTH
		assert 1 == UsersModel.add(name, "secret")
		assert UsersModel::ERR_BAD_USERNAME ==
		UsersModel.add(name+"a", "secret")
	end
	test "password can be blank" do
		assert 1 == UsersModel.add("kevin", "")
	end
	test "password should not be too long" do
		password = "a"*UsersModel::MAX_PASSWORD_LENGTH
		assert 1 == UsersModel.add("kevin", password)
		assert UsersModel::ERR_BAD_PASSWORD ==
		UsersModel.add("steve", password+"a")
	end
	test "cannot add an already registered user" do
		assert 1 == UsersModel.add("kevin", "secret")
		assert UsersModel::ERR_USER_EXISTS ==
		UsersModel.add("kevin", "secret")
	end
	test "usernames are case-sensitive" do
		assert 1 == UsersModel.add("kevin", "secret")
		assert 1 == UsersModel.add("Kevin", "secret")
		assert UsersModel::ERR_BAD_CREDENTIALS ==
		UsersModel.login("keviN", "secret")
	end
	test "passwords are case-sensitive" do
		assert 1 == UsersModel.add("kevin", "secret")
		assert UsersModel::ERR_BAD_CREDENTIALS ==
		UsersModel.login("kevin", "Secret")
	end
	test "non-registered user cannot login" do
		assert UsersModel::ERR_BAD_CREDENTIALS ==
		UsersModel.login("ghost", "secret")
	end
	test "incorrect password, cannot login" do
		assert 1 == UsersModel.add("kevin", "secret")
		assert UsersModel::ERR_BAD_CREDENTIALS ==
		UsersModel.login("kevin", "Secret")
	end
	test "correct password, count increments" do
		assert 1 == UsersModel.add("kevin", "secret")
		assert 2 == UsersModel.login("kevin", "secret")
		assert 1 == UsersModel.add("calvin", "secret")
		assert 2 == UsersModel.login("calvin", "secret")
		assert 3 == UsersModel.login("kevin", "secret")
	end


end
