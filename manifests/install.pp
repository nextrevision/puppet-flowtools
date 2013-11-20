# == Class flowtools::intall
#
class flowtools::install {
  include flowtools::params

  package { $flowtools::params::package_name:
    ensure => present,
  }
}
