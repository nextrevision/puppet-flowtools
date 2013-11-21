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
        it do
          should contain_service('flow-capture').with({
            'ensure'     => 'running',
            'enable'     => 'true',
            'hasrestart' => 'true',
          })
        end
        it do 
          should contain_file('/var/flow').with({
            'ensure' => 'directory',
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
        it do
          should contain_service('flow-capture').with({
            'ensure'     => 'stopped',
            'enable'     => 'false',
            'hasrestart' => 'true',
          })
        end
        it do 
          should contain_file('/data/flows').with({
            'ensure' => 'directory',
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
