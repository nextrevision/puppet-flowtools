require 'spec_helper'

describe 'flowtools' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      concatdir = '/dne' if concatdir.nil?
      let(:facts) {{
        :osfamily       => osfamily,
        :concat_basedir => concatdir
      }}
      describe "flowtools class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        it { should contain_class('flowtools::install') }
        it { should contain_class('flowtools::config') }
        it { should contain_class('flowtools::service') }
        it { should contain_package('flow-tools').with_ensure('present') }
        if osfamily == 'RedHat'
          it 'should create the install package on the system' do
            should contain_file('/opt/flow-tools-0.68.5.1-1.x86_64.rpm').with({
              'source' => 'puppet:///modules/flowtools/flow-tools-0.68.5.1-1.x86_64.rpm',
              'before' => 'Package[flow-tools]',
            })
          end
          it do
            should contain_package('flow-tools').with({
              'ensure'   => 'present',
              'name'     => '/opt/flow-tools-0.68.5.1-1.x86_64.rpm',
              'source'   => '/opt/flow-tools-0.68.5.1-1.x86_64.rpm',
              'provider' => 'rpm',
            })
          end
        end
        it 'should install the init.d flow-capture file' do
          should contain_file('/etc/init.d/flow-capture').with({
            'owner' => 'root',
            'group' => 'root',
            'mode'  => '0755',
          })
        end
        it { should contain_file('/var/flow') }
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
      describe "flowtools class without managing service" do
        let(:params) {{ :manage_service => false }}
        it { should compile.with_all_deps }
        it { should_not contain_service('flow-capture') }
      end
      describe "flowtools class with custom package settings on #{osfamily}" do
        if osfamily == 'Debian'
          let(:params) {{
            'package_name'     => '/tmp/flowtoolz',
            'package_provider' => 'dpkg',
            'package_source'   => 'puppet:///modules/custom/flowtoolz.deb',
          }}
          it 'should create the install package on the system' do
            should contain_file('/tmp/flowtoolz').with({
              'source' => 'puppet:///modules/custom/flowtoolz.deb',
              'before' => 'Package[flow-tools]',
            })
          end
          it do
            should contain_package('flow-tools').with({
              'ensure'   => 'present',
              'name'     => '/tmp/flowtoolz',
              'source'   => '/tmp/flowtoolz',
              'provider' => 'dpkg',
            })
          end
        end
        if osfamily == 'RedHat'
          let(:params) {{
            'package_name'     => 'flowtools',
            'package_provider' => 'yum',
            'package_source'   => false,
          }}
          it do
            should contain_package('flow-tools').only_with({
              'ensure'   => 'present',
              'name'     => 'flowtools',
              'provider' => 'yum',
            })
          end
        end
      end
      describe "flowtools class with invalid parameter on #{osfamily}" do
        let(:params) {{ :capture => 'notvalid' }}
        it { expect { should contain_file('/etc/flow-tools') }.to raise_error(Puppet::Error, /not a boolean/) }
      end
    end
  end
  context 'unsupported operating system' do
    describe 'flowtools class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}
      it { expect { should contain_file('/etc/flow-tools') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
