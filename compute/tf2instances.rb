# Converts the output from terraform into a usable instances list
#
# input looks like
#
#  server = 10.11.12.13
#
# output looks like
#
# 10.11.12.13 server os login
#
# usage: terraform output | ruby tf2instances.rb <os> <login> > ../instances
#

abort "need 2 args: os login" unless ARGV.size == 2

os, login = ARGV.shift 2

STDIN.each do |line|
  name, ip = line.chomp.split(" = ")

  STDOUT.puts [ip, name, os, login].join(" ")
end
