require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'

include RSpecSystemPuppet::Helpers

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  c.tty = true
  c.include RSpecSystemPuppet::Helpers

  c.before :suite do
    puppet_install
    puppet_module_install(:source => proj_root, :module_name => 'flowtools')
    shell('puppet module install puppetlabs-stdlib')
    shell('puppet module install puppetlabs-concat')
  end

  c.before(:all) do
    shell('mkdir -p /dne')
  end
  c.after(:all) do
    shell('rm -rf /dne')
    shell('ps ax | grep flow-capture')
    shell("netstat -lnup | egrep -q '(5555|5656)'")
    shell('test -d /flows/device1')
    shell('test -d /flows/device2')
  end

end
