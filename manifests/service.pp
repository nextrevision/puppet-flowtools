# == Class flowtools::service
#
# This class is meant to be called from flowtools
# It ensure the service is running
#
class flowtools::service {
  include flowtools::params

  service { $flowtools::params::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
