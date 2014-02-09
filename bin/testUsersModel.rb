#!/usr/bin/env ruby
load File.expand_path("../../config/environments/production.rb", __FILE__)
puts "Hello"
u = UserData.new("Kevin Zhang")
u.save()
puts "DONE"

