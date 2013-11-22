require 'spec_helper'

describe 'flowtools::device' do
  context 'on supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|

      concatdir = '/dne' if concatdir.nil?

      describe "with required params on #{osfamily}" do
        let(:title) { 'device1' }
        let(:params) {{
          :ip_address => '127.0.0.1',
          :port => '9999',
        }}
        let(:facts) {{
          :osfamily => osfamily,
          :concat_basedir => concatdir
        }}
        let(:pre_condition) { 'include flowtools' }

        it { should include_class('flowtools::params') }
        it 'should create a device directory for flow data' do
          should contain_file('/var/flow/device1').with({
            'ensure' => 'directory',
          })
        end
        it 'should contain flow-capture concat fragment' do
          should contain_concat__fragment('flowtools-device-device1').with({
            'target'  => '/etc/flow-tools/flow-capture.conf',
            'content' => "-w /var/flow/device1  0.0.0.0/127.0.0.1/9999\n",
            'order'   => '05',
          })
        end
      end

      describe "with all params on #{osfamily}" do
        let(:title) { 'device1' }
        let(:params) {{
          :ip_address => '127.0.0.1',
          :port => '9999',
          :listen => '192.168.1.1',
          :options => '-V 5'
        }}
        let(:facts) {{
          :osfamily => osfamily,
          :concat_basedir => concatdir
        }}
        let(:pre_condition) { 'include flowtools' }

        it 'should contain flow-capture concat fragment' do
          should contain_concat__fragment('flowtools-device-device1').with({
            'target'  => '/etc/flow-tools/flow-capture.conf',
            'content' => "-w /var/flow/device1 -V 5 192.168.1.1/127.0.0.1/9999\n",
            'order'   => '05',
          })
        end
      end

      describe "with a custom flow directory specified" do
        let(:title) { 'device1' }
        let(:params) {{
          :ip_address => '127.0.0.1',
          :port => '9999',
        }}
        let(:facts) {{
          :osfamily => osfamily,
          :concat_basedir => concatdir
        }}
        let(:pre_condition) { 'class { "flowtools": flow_dir => "/flows" }' }

        it { should include_class('flowtools::params') }
        it 'should create a device directory for flow data' do
          should contain_file('/flows/device1').with({
            'ensure' => 'directory',
          })
        end
        it 'should contain flow-capture concat fragment' do
          should contain_concat__fragment('flowtools-device-device1').with({
            'target'  => '/etc/flow-tools/flow-capture.conf',
            'content' => "-w /flows/device1  0.0.0.0/127.0.0.1/9999\n",
            'order'   => '05',
          })
        end
      end

      describe "flowtools::device with no parameters on #{osfamily}" do
        let(:title) { 'device1' }
        let(:params) {{  }}
        let(:facts) {{
          :osfamily => osfamily,
          :concat_basedir => concatdir
        }}
        it { expect { should }.to raise_error(Puppet::Error, /Must pass/) }
      end

    end
  end
end
