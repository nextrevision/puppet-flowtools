require 'spec_helper_system'

describe 'basic tests' do
  it 'class should work without errors' do
    pp = <<-EOS
      class { 'flowtools':
        enabled  => true,
        flow_dir => '/flows',
      }
      flowtools::device { 'device1':
        ip_address => '125.0.0.23',
        port       => '5555',
      }
      flowtools::device { 'device2':
        ip_address => '125.0.0.25',
        port       => '5656',
      }
    EOS

    puppet_apply(pp) do |r|
      r.exit_code.should == 2
    end
  end
end
