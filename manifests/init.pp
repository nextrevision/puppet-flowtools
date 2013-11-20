# == Class: flowtools
#
# Full description of class flowtools here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class flowtools (
) inherits flowtools::params {

  # validate parameters here

  class { 'flowtools::install': } ->
  class { 'flowtools::config': } ~>
  class { 'flowtools::service': } ->
  Class['flowtools']
}
