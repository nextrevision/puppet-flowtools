require 'spec_helper'

describe 'flowtools' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      concatdir = '/dne' if concatdir.nil?
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
      end
      describe "flowtools class with capture false parameter on #{osfamily}" do
        let(:params) {{
          :capture => false,
          :flow_dir => '/data/flows'
        }}
        let(:facts) {{
          :osfamily => osfamily,
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
          :osfamily => osfamily,
          :concat_basedir => concatdir
        }}
        it { expect { should }.to raise_error(Puppet::Error, /not a boolean/) }
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
