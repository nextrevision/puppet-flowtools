# == Type: flowtools::device
#
# Configures flow-capture to listen for a specified device. It ensures the
# destination directory for the device flows is created, then adds an entry
# into the flow-capture configuration file to listen for the flows.
#
# === Parameters
#
# [ip_address]
#   The IP address of the device sending the flow data.
#   can be sepcified as 0 or 0.0.0.0 to capture from all sources
#
# [port]
#    UDP port to listen on for flow data
#
# [listen]
#    IP address to bind the flow-capture service to
#    can be specified as 0 or 0.0.0.0 to listen on all interfaces
#
# [options]
#    Additional options to pass to flow-capture
#
define flowtools::device (
  $ip_address,
  $port,
  $listen = '0.0.0.0',
  $options = '',
) {

  include flowtools::params

  # Validate params
  validate_string($ip_address)
  validate_re($port, '^[0-9]+$')
  validate_string($listen)
  validate_string($options)

  # Verify the device directory for flows is a valid path
  $device_dir = "${flowtools::flow_dir}/${title}"
  validate_absolute_path($device_dir)

  # Device directory in the flow directory to save flow data
  file { $device_dir:
    ensure  => directory,
  }

  # Add line to flow-capture config
  concat::fragment { "flowtools-device-${title}":
    target  => $flowtools::params::config_file,
    content => "-w ${device_dir} ${options} ${listen}/${ip_address}/${port}\n",
    order   => '05',
  }

}
