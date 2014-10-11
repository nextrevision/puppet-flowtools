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
# [capture]
#   boolean value to enable/disable flow-capture on startup
#   and to manage the service itself (running/stopped)
#
# [flow_dir]
#    directory to store the capture flows
#
# [manage_service]
#    manage the flow tools service
#
# [package_name]
#    name of the flow tools package to install
#
# [package_provider]
#    specify provider to use for installing package
#
# [package_source]
#    source of flow tools package to use with a local package provider
#    if using a RedHat osfamily and you want to install from a yum repo,
#    set this value to false and override the other package_* parameters
#
# [devices]
#    hash of devices to create with flowtools::device
#
# [devices_defaults]
#    default settings for devices (used in create_resources)
#
# [hiera_device]
#    (deprecated) pass a data from hiera to define flowtools::device(s)
class flowtools (
  $capture          = true,
  $flow_dir         = $flowtools::params::flow_dir,
  $manage_service   = true,
  $package_name     = $flowtools::params::package_name,
  $package_provider = $flowtools::params::package_provider,
  $package_source   = $flowtools::params::package_source,
  $devices          = {},
  $devices_defaults = {},
  # Deprecated params
  $hiera_device     = {},
) inherits flowtools::params {

  # validate parameters here
  validate_bool($capture)
  validate_absolute_path($flow_dir)
  validate_bool($manage_service)
  validate_string($package_name)
  validate_string($package_provider)
  validate_hash($devices)
  validate_hash($devices_defaults)
  validate_hash($hiera_device)

  class { 'flowtools::install': } ->
  class { 'flowtools::config': } ~>
  class { 'flowtools::service': } ->
  Class['flowtools']

  if $hiera_device {
    warning('hiera_device is deprecated, use devices param instead')
    $devices_real = $hiera_device
  } else {
    $devices_real = $devices
  }

  if !empty($devices_real) {
    create_resources('flowtools::device', $devices, $devices_defaults)
  }
}
