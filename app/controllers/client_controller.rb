class UsersModel
	## The success return code
    SUCCESS               =   1

    ## Cannot find the user/password pair in the database (for login only)
    ERR_BAD_CREDENTIALS   =  -1

    ## trying to add a user that already exists (for add only)
    ERR_USER_EXISTS       =  -2

    ## invalid user name (empty or longer than MAX_USERNAME_LENGTH) (for add, or login)
    ERR_BAD_USERNAME      =  -3

    ## invalid password name (longer than MAX_PASSWORD_LENGTH) (for add)
    ERR_BAD_PASSWORD      =  -4


    ## The maximum length of user name
    MAX_USERNAME_LENGTH = 128

    ## The maximum length of the passwords
    MAX_PASSWORD_LENGTH = 128
    
    def initialize()
        UsersModel._reset()
	end

    def self.login(user, password)
        # @param user: (string) the username
        # @param password: (string) the password

        # This function checks the user/password in the database.
        # * On success, the function updates the count of logins in the database.
        # * On success the result is either the number of logins (including this one) (>= 1)
        # * On failure the result is an error code (< 0) from the list below
        #    * ERR_BAD_CREDENTIALS

        old_user = UserData.find_by(username:user)
        if old_user == nil
            return ERR_BAD_CREDENTIALS
        end
        if old_user.password != password
            return ERR_BAD_CREDENTIALS
        end
        old_user.count += 1
        old_user.save()
        return old_user.count
    end

    def self.valid_username(username)
        return username != "" &&
        username.length() <= MAX_USERNAME_LENGTH
    end

    def self.valid_password(password)
        return password.length() <=
        MAX_PASSWORD_LENGTH
    end

    def self.add(user, password)
        
        # @param user: (string) the username
        # @param password: (string) the password

        # This function checks that the user does not exists, the user name is not empty. (the password may be empty).

        # * On success the function adds a row to the DB, with the count initialized to 1
        # * On success the result is the count of logins
        # * On failure the result is an error code (<0) from the list below
        #    * ERR_BAD_USERNAME, ERR_BAD_PASSWORD, ERR_USER_EXISTS

        new_user = UserData.find_by(username:user)
        if new_user != nil
            return ERR_USER_EXISTS
        end

        if !UsersModel.valid_username(user)
            return ERR_BAD_USERNAME
        end

        if !UsersModel.valid_password(password)
            return ERR_BAD_PASSWORD
        end

        new_user = UserData.new(username:user, password:password, count:1)
 		new_user.save()
        return new_user.count
    end


    # Used from constructor and self test
    def self._reset()
    	UserData.delete_all()
    end

    def self.TESTAPI_resetFixture()
        UsersModel._reset()
    end

    # def TESTAPI_resetFixture(self):
    #     """
    #     This function is used only for testing, and should clear the database of all rows.

    #     It should always return SUCCESS (1)

    #     Used for testing
    #     """
    #     self._reset ()
end

class ClientController < ApplicationController
	def index
	end

	def post
		@request = request()
		type = @request.headers["Content-Type"].split(";")
		if !@request.post?() || !(type.include?("application/json"))
			return render(:json=>{}, status:500)
		end
		if @request.fullpath == "/users/login" ||
			@request.fullpath == "/users/add"
			if params.keys.include?("user") &&
				params.keys.include?("password")
				username = params["user"]
				password = params["password"]
				if @request.path == "/users/login"
					rval = UsersModel.login(username, password)
				else
					rval = UsersModel.add(username, password)
				end
				if rval < 0
					resp = {"errCode"=>rval}
				else
					resp = {"errCode"=>UsersModel::SUCCESS,
						"count"=>rval}
				end
				puts "response is #{rval}"
				return render(:json=>resp, status:200)
			else
				return render(:json=>{}, status:500)
			end
		else
			return render(:json=>{}, status:404)
		end
	end

    def test
        @request = request()
        type = @request.headers["Content-Type"].split(";")
        if !@request.post?() || !(type.include?("application/json"))
            return render(:json=>{}, status:500)
        end
        if @request.fullpath == "/TESTAPI/resetFixture"
            UsersModel.TESTAPI_resetFixture()
            return render(:json=>{}, status:200)
        elsif @request.fullpath == "/TESTAPI/unitTests"
            path = File.expand_path("../../../test/models", __FILE__)
            command = "heroku run rake test "+path+"/user_data_test.rb"+
            " >> "+path+"/test_output.txt"
            system(command)
            begin
                file = File.new(path+"/test_output.txt", "r")
                # readlines returns an array and delimits by "\n"
                contents = file.readlines()
                puts contents.join()
                file.close()
                system("rm -rf "+path+"/test_output.txt")
                result = []
                if contents.length() > 0
                    # results are in the last line
                    line = contents[contents.length()-1]
                    delimited = ""
                    line.each_char{|letter|
                        if letter == ","
                            delimited += " "
                        else
                            delimited += letter
                        end
                    }
                    result = delimited.split(" ")
                end
                if result.include?("tests") &&
                    result.include?("failures")
                    numTests = result[result.index("tests")-1].to_i()
                    numFails = result[result.index("failures")-1].to_i()
                    resp = {"nrFailed"=>numFails,
                        "output"=>contents.join(), "totalTests"=>numTests}
                    return render(:json=>resp, status:200)
                else
                    resp = {"nrFailed"=>0, "output"=>"",
                    "totalTests"=>0}
                    return render(:json=>resp, status:200)
                end
            rescue => error
                resp = {"nrFailed"=>0, "output"=>"",
                    "totalTests"=>0}
                return render(:json=>resp, status:200)
            end
        end
    end
end
