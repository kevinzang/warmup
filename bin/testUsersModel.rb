#!/usr/bin/env ruby
require "../../app/models/user_data.rb"
puts "Hello"
u = UserData.new("Kevin Zhang")
u.save()
puts "DONE"

