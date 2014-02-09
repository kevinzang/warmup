require 'spec_helper'
require File.expand_path("../../../app/controllers/client_controller", __FILE__)

describe "Clients" do
	before(:each) {
		UsersModel.TESTAPI_resetFixture()
	}
	after(:each) {
		UsersModel.TESTAPI_resetFixture()
	}
    describe "add user" do
        it "should not have a blank username" do
            UsersModel.add("", "secret").should == UsersModel::ERR_BAD_USERNAME
        end
	    it "should not have a username that is too long" do
			name = "a"*UsersModel::MAX_USERNAME_LENGTH
			UsersModel.add(name, "secret").should == 1
			UsersModel.add(name+"a", "secret").should ==
			UsersModel::ERR_BAD_USERNAME
		end
		it "can have a blank password" do
			UsersModel.add("kevin", "").should == 1
		end
		it "should not have a password that is too long" do
			password = "a"*UsersModel::MAX_PASSWORD_LENGTH
			UsersModel.add("kevin", password).should == 1
			UsersModel.add("steve", password+"a").should ==
			UsersModel::ERR_BAD_PASSWORD
		end
		it "should not add an already registered user" do
			UsersModel.add("kevin", "secret").should == 1
			UsersModel.add("kevin", "secret").should ==
			UsersModel::ERR_USER_EXISTS
		end
		it "should have usernames that are case-sensitive" do
			UsersModel.add("kevin", "secret").should == 1
			UsersModel.add("Kevin", "secret").should == 1
			UsersModel.login("keviN", "secret").should ==
			UsersModel::ERR_BAD_CREDENTIALS
		end
	end

	describe "login user" do
		it "should have passwords that are case-sensitive" do
			UsersModel.add("kevin", "secret").should == 1
			UsersModel.login("kevin", "Secret").should ==
			UsersModel::ERR_BAD_CREDENTIALS
		end
		it "should not login a non-registered user" do
			UsersModel.login("ghost", "secret").should ==
			UsersModel::ERR_BAD_CREDENTIALS
		end
		it "should not login if incorrect password" do
			UsersModel.add("kevin", "secret").should == 1
			UsersModel.login("kevin", "Secret").should ==
			UsersModel::ERR_BAD_CREDENTIALS
		end
		it "should increment count on correct username/password" do
			UsersModel.add("kevin", "secret").should == 1
			UsersModel.login("kevin", "secret").should == 2
			UsersModel.add("calvin", "secret").should == 1
			UsersModel.login("calvin", "secret").should == 2
			UsersModel.login("kevin", "secret").should == 3
		end
	end
end
