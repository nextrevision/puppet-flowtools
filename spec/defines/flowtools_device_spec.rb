require 'spec_helper'

describe 'flowtools::device' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|

      concatdir = '/dne' if concatdir.nil?

      describe "flowtools::device with required params on #{osfamily}" do
        let(:title) { 'device1' }
        let(:params) {{
          :ip_address => '127.0.0.1',
          :port => '9999',
        }}
        let(:facts) {{
          :osfamily => osfamily,
          :concat_basedir => concatdir
        }}
        it { should include_class('flowtools::params') }
        it 'should contain flow-capture concat fragment' do
          should contain_concat__fragment('flowtools-device-device1').with({
            'target'  => '/etc/flow-tools/flow-capture.conf',
            'content' => "-w /device1  0.0.0.0/127.0.0.1/9999\n",
            'order'   => '05',
          })
        end
      end

      describe "flowtools::device with all params on #{osfamily}" do
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
        it 'should contain flow-capture concat fragment' do
          should contain_concat__fragment('flowtools-device-device1').with({
            'target'  => '/etc/flow-tools/flow-capture.conf',
            'content' => "-w /device1 -V 5 192.168.1.1/127.0.0.1/9999\n",
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
