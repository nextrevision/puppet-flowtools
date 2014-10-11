# == Class flowtools::intall
#
# RedHat systems do not have flow-tools in their repos, so we need to install
# via RPM. Debian systems can be installed via apt and default repos
#
class flowtools::install {
  include flowtools::params

  if $flowtools::package_source {
    file { $flowtools::package_name:
      ensure => present,
      source => $flowtools::package_source,
      before => Package['flow-tools'],
    }
    Package<| title == 'flow-tools' |> {
      source => $flowtools::package_name
    }
  }

  package { 'flow-tools':
    ensure   => present,
    name     => $flowtools::package_name,
    provider => $flowtools::package_provider
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
