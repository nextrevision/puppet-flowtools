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
        it { should include_class('flowtools::params') }
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
