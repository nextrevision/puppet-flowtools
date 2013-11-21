# == Class flowtools::service
#
# This class is meant to be called from flowtools
# It ensure the service is running
#
class flowtools::service {
  include flowtools::params

  $ensure = $flowtools::enabled ? {
    true  => 'running',
    false => 'stopped',
  }

  service { $flowtools::params::service_name:
    ensure     => $ensure,
    enable     => $flowtools::enabled,
    hasstatus  => false,
    hasrestart => true,
  }
}
