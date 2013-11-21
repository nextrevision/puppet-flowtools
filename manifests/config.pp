# == Class flowtools::config
#
# This class is called from flowtools
#
class flowtools::config {
    include flowtools::params

    file { $flowtools::params::config_dir:
      ensure => directory
    }

    concat { $flowtools::params::config_file:
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
    }

    concat::fragment { 'flowtools-device-header':
      target  => $flowtools::params::config_file,
      content => "# File managed by Puppet #\n\n",
      order   => '01',
    }
}
