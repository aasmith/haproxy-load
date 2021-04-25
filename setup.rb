require "tempfile"

# commands
#
#  cfg  : push cfgs to all instances
#  init : run initial setup on all instances
#
#
#  setup cfgs <config-name> <config-params>


def hosts
  entries = File.foreach("instances").map(&:split).map do |ip, role, os, login|
    "%s %s" % [ip, role]
  end

  script = <<~SHELL
    sudo tee -a /etc/hosts >> /dev/null << EOF
    #{entries.join("\n")}
    EOF
  SHELL

  script
end

def roles
  @roles ||= File.foreach("instances").map(&:split).map{|a|a[1]}.compact
end

def exists?(role)
  roles.include? role
end

# Return the ip, role, os, login of the instance with the given role
def lookup(role)
  File.foreach("instances").map{|e| e.split}.rassoc(role) or raise "no such role"
end

def ip(role)
  lookup(role)[0]
end

def sys(cmd, background: false)
  warn cmd
  background ? spawn(cmd) : system(cmd)
end

def wait
  warn "waiting..."
  start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

  Process.waitall

  elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
  warn "all runs completed in %.1f secs" % elapsed
end

def syscfg(ip, role, os, login)

  Tempfile.create("init") do |script|

    Dir.glob("scripts/#{os}/{common,#{role}}.sh").each do |s|
      warn "appending #{s}"

      script.write File.read(s)
    end

    script.write hosts
    script.fsync

    sys 'scp -B -o User=%s "%s" %s:/tmp/init.sh' % [
      login,
      script.path,
      ip
    ]

  end

end

def appcfg(ip, role, os, login)
  sys 'rsync -ai methods %s@%s:' % [ login, ip ]
end

def init
  pids = []

  roles.each do |role|
    ip, role, os, login = lookup role

    sys 'ssh -l %s %s bash /tmp/init.sh' % [login, ip], background: true
  end

  wait
end

def try(method)
  warn "Trying method %s..." % method

  pids = []

  # order sensitive -- don't want proxy setting up before the server
  %w[logspout server proxy client].each do |role|
    unless exists?(role)
      warn "skipping role %s" % role
      next
    end

    ip, role, os, login = lookup role

    system "figlet %s" % role

    sys 'ssh %s@%s bash methods/%s/%s.sh' % [ login, ip, method, role ], background: true
  end

  wait
end

def analyze(method)
  ip, role, os, login = lookup "client"

  rev = Time.now.to_i

  system "mkdir -p 'results/%s_%s/config'" % [method, rev]
  system "scp %s@%s:~/results/* results/%s_%s" % [login, ip, method, rev]
  system "scp %s@%s:~/methods/%s/* results/%s_%s/config" % [login, ip, method, method, rev]

  ip, role, os, login = lookup "proxy"
  system "scp %s@%s:/tmp/init.sh results/%s_%s/config" % [login, ip, method, rev]
end

COMMANDS = %w(init syscfg appcfg try analyze science)

def usage
  warn "usage: %s command" % $0
  warn "commands: #{COMMANDS.join(" ")}"
  abort
end

usage unless COMMANDS.include?(command = ARGV.shift)

case command
when "try" then
  abort "need methodology name" unless ARGV.any?
  try ARGV.first

when "analyze" then
  abort "need methodology name" unless ARGV.any?
  analyze ARGV.first

when "science" then
  abort "need methodology name" unless ARGV.any?
  try ARGV.first
  analyze ARGV.first

when "init" then
  init

else
  puts "Running %s for each instance" % command

  roles.each do |role|
    ip, _, os, login = lookup(role)

    system "figlet %s" % role
    send command, ip, role, os, login
  end
end
