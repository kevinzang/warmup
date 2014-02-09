#!/usr/bin/env ruby
require File.expand_path("../../app/models/user_data.rb", __FILE__)
puts "Hello"
u = UserData.new("Kevin Zhang")
u.save()
puts "DONE"

