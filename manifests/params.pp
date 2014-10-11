# == Class flowtools::params
#
# This class is meant to be called from flowtools
# It sets variables according to platform
#
class flowtools::params {

  $service_name = 'flow-capture'
  $config_dir = '/etc/flow-tools'
  $config_file = '/etc/flow-tools/flow-capture.conf'
  $flow_dir = '/var/flow'

  case $::osfamily {
    'Debian': {
      $package_name = 'flow-tools'
      $package_provider = 'apt'
      $package_source = undef
    }
    'RedHat', 'Amazon': {
      $package_name = '/opt/flow-tools-0.68.5.1-1.x86_64.rpm'
      $package_provider = 'rpm'
      $package_source = 'puppet:///modules/flowtools/flow-tools-0.68.5.1-1.x86_64.rpm'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
