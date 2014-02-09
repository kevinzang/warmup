#!/usr/bin/env ruby
failed = 0
tests = []

def test_1()
	UsersModel.TESTAPI_resetFixture()
	if UsersModel.SUCCESS == UsersModel.add("kevin", "zhang")
		return ""
	else
		return "Failed: user name is valid"
		failed += 1
	end
end

test_1()
puts failed

