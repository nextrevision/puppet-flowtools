# == Class: flowtools
#
# Install flow-tools, then generate an empty config, and finally manage the
# flow-capture service. Flow-tools is absent from the Epel, RPMforge, and
# standard CentOS repositories, so a RPM must be provided. Granted this is
# not a very scalable/maintainable approach, it solves the issue for RedHat
# family devices. Debian-family systems can install via the repos provided.
#
# Although this class facilitates flow-tools as a whole, it will fail unless
# the define "flowtools::device" is specified because the initial configuration
# file will be empty and the flow-capture service will not start. If you are
# going to install flow-tools and want flow-capture to work, then use the define
# as well. Otherwise, you can install flow-tools and set [enabled] to false to
# only install the tools.
#
# === Parameters
#
# [enabled]
#   boolean value to enable/disable flow-capture on startup
#   and to manage the service itself (running/stopped)
#
# [flow_dir]
#    directory to store the capture flows
#
class flowtools (
  $enabled = true,
  $flow_dir = $flowtools::params::flow_dir,
) inherits flowtools::params {

  # validate parameters here
  validate_bool($enabled)
  validate_absolute_path($flow_dir)

  class { 'flowtools::install': } ->
  class { 'flowtools::config': } ~>
  class { 'flowtools::service': } ->
  Class['flowtools']
}
