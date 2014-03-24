require 'spec_helper'
require 'hiera'

describe 'flowtools' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|

      concatdir = '/dne' if concatdir.nil?
      let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
      hiera = Hiera.new(:config => 'spec/fixtures/hiera/hiera.yaml')

      describe "flowtools class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
          :concat_basedir => concatdir
        }}
        it { should include_class('flowtools::params') }
        it { should contain_class('flowtools::install') }
        it { should contain_class('flowtools::config') }
        it { should contain_class('flowtools::service') }
        it 'should install flow-tools package' do
          should contain_package('flow-tools').with({
            'ensure' => 'present',
          })
        end
        it 'should install the init.d flow-capture file' do
          should contain_file('/etc/init.d/flow-capture').with({
            'owner' => 'root',
            'group' => 'root',
            'mode'  => '0755',
          })
        end
        it 'should make the flow directory' do 
          should contain_file('/var/flow').with({
            'ensure' => 'directory',
          })
        end
        it 'should manage the flow-tools config directory' do
          should contain_file('/etc/flow-tools').with({
            'ensure' => 'directory',
          })
        end
        it 'should setup /etc/flow-tools/flow-capture.conf as a concat resource' do
          should contain_concat('/etc/flow-tools/flow-capture.conf').with({
            'owner' => 'root',
            'group' => 'root',
          })
        end
        it 'should contain a header concat fragment' do
          should contain_concat__fragment('flowtools-device-header').with({
            'target'  => '/etc/flow-tools/flow-capture.conf',
            'content' => "# File managed by Puppet #\n\n",
            'order'   => '01',
          })
        end
        it 'should start the flow-capture service' do
          should contain_service('flow-capture').with({
            'ensure'     => 'running',
            'enable'     => 'true',
            'hasrestart' => 'true',
          })
        end
        it { should_not contain_flowtools__device('br1') }
        it { should_not contain_flowtools__device('router1') }
      end
      describe "flowtools class with capture false parameter on #{osfamily}" do
        let(:params) {{
          :capture  => false,
          :flow_dir => '/data/flows'
        }}
        let(:facts) {{
          :osfamily       => osfamily,
          :concat_basedir => concatdir
        }}
        it 'should create the custom flow directory' do 
          should contain_file('/data/flows').with({
            'ensure' => 'directory',
          })
        end
        it 'should disable and not run the flow-capture service' do
          should contain_service('flow-capture').with({
            'ensure'     => 'stopped',
            'enable'     => 'false',
            'hasrestart' => 'true',
          })
        end
      end
      describe "flowtools class with invalid parameter on #{osfamily}" do
        let(:params) {{ :capture => 'notvalid' }}
        let(:facts) {{
          :osfamily       => osfamily,
          :concat_basedir => concatdir
        }}
        it { expect { should }.to raise_error(Puppet::Error, /not a boolean/) }
      end
      describe "flowtools class with hiera data from common lookup on #{osfamily}" do
        hiera_flowtools_capture = hiera.lookup('flowtools::capture', nil, nil)
        hiera_flowtools_flow_dir = hiera.lookup('flowtools::flow_dir', nil, nil)
        hiera_flowtools_device = hiera.lookup('flowtools::hiera_device', nil, nil)
        let(:facts) {{
          :osfamily       => osfamily,
          :concat_basedir => concatdir
        }}
        let(:params) {{ 
          :capture      => hiera_flowtools_capture,
          :flow_dir     => hiera_flowtools_flow_dir,
          :hiera_device => hiera_flowtools_device
        }}
        it 'should create the hiera flow directory' do 
          should contain_file('/mnt/flow1').with({
            'ensure' => 'directory',
          })
        end
        it 'should enable and not run the flow-capture service' do
          should contain_service('flow-capture').with({
            'ensure'     => 'running',
            'enable'     => 'true',
            'hasrestart' => 'true',
          })
        end
        it 'should create flowtools::device br1' do
          should contain_flowtools__device('br1').with(
            'ip_address' => '1.1.1.1',
            'port'       => '8777'
          )
        end
        it 'should create flowtools::device br2' do
          should contain_flowtools__device('br2').with(
            'ip_address' => '2.2.2.2',
            'port'       => '7777'
          )
        end
      end
      describe "flowtools class with hiera data from alternate common lookup on #{osfamily}" do
        hiera_flowtools = hiera.lookup('flowtools', nil, nil)
        let(:facts) {{
          :osfamily       => osfamily,
          :concat_basedir => concatdir
        }}
        let(:params) {{ 
          :capture      => hiera_flowtools['capture'],
          :flow_dir     => hiera_flowtools['flow_dir'],
          :hiera_device => hiera_flowtools['hiera_device']
        }}
        it 'should create the hiera flow directory' do 
          should contain_file('/srv/flows').with({
            'ensure' => 'directory',
          })
        end
        it 'should enable and run the flow-capture service' do
          should contain_service('flow-capture').with({
            'ensure'     => 'running',
            'enable'     => 'true',
            'hasrestart' => 'true',
          })
        end
        it 'should create flowtools::device router1' do
          should contain_flowtools__device('router1').with(
            'ip_address' => '10.0.0.1',
            'port'       => '9997'
          )
        end
        it 'should create flowtools::device router2' do
          should contain_flowtools__device('router2').with(
            'ip_address' => '192.168.1.1',
            'port'       => '9998'
          )
        end
      end
    end
  end
  context 'unsupported operating system' do
    describe 'flowtools class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}
      it { expect { should }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
