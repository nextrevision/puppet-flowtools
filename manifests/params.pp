# == Class flowtools::params
#
# This class is meant to be called from flowtools
# It sets variables according to platform
#
class flowtools::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'flowtools'
      $service_name = 'flowtools'
    }
    'RedHat', 'Amazon': {
      $package_name = 'flowtools'
      $service_name = 'flowtools'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
