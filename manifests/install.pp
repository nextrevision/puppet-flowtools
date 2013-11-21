# == Class flowtools::intall
#
# RedHat systems do not have flow-tools in their repos, so we need to install
# via RPM. Debian systems can be installed via apt and default repos
#
class flowtools::install {
  include flowtools::params

  if $::osfamily == 'RedHat' {
    file { $flowtools::params::package_name:
      ensure => present,
      source => 'puppet:///modules/flowtools/flow-tools-0.68.5.1-1.x86_64.rpm',
      before => Package['flow-tools'],
    }
  }

  package { 'flow-tools':
    ensure   => present,
    source   => $flowtools::params::package_name,
    provider => $flowtools::params::package_provider
  }

  file { $flowtools::flow_dir:
    ensure => directory
  }

  file { '/etc/init.d/flow-capture':
    ensure => file,
    source => 'puppet:///modules/flowtools/flow-capture.init',
    mode   => '0755',
    owner  => 'root',
    group  => 'root'
  }

}
