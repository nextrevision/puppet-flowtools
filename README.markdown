#puppet-flowtools

[![Build Status](https://travis-ci.org/nextrevision/puppet-flowtools.png?branch=master)](https://travis-ci.org/nextrevision/puppet-flowtools)

####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup - The basics of getting started with puppet-flowtools](#setup)
    * [What puppet-flowtools affects](#what-[modulename]-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with puppet-flowtools](#beginning-with-[Modulename])
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

This module is responsible for installing flow-tools, configuring flow-capture, and running flow-capture on specified interfaces and ports for specified devices. 

##Module Description

This module is responsible for installing flow-tools on the system. Once flow-tools has been successfully installed, the module will generate an empty config file (default: `/etc/flow-tools/flow-capture`). The service is then started/enabled if specified (default: `true`), and will begin receiving flow data and writing it to a directory (default: `/var/flow`).

The module has a device type which configures flow-capture to listen on an interface/port for a device. If using flow-capture, this is required for the module to function properly, otherwise flow-capture will fail to start due to the emtpy config file.

This module can be used to only install flow-tools, with the use of the `capture` parameter described below.

##Setup

###What puppet-flowtools affects

* /etc/init.d/flow-capture
* /etc/flow-tools/flow-capture.conf
* /usr/local/flow-tools/ (RedHat family systems only)

###Setup Requirements

This module is dependent on puppetlabs/concat and puppetlabs/stdlib. As for puppetlabs/concat, you must have `pluginsync` set to true on systems you wish to use with this module.
  
###Beginning with puppet-flowtools

To get started, simply include the flow-tools class and define a capture device:

```
include flowtools
flowtools::device { 'device1':
  ip_address => '192.168.1.1',
  port       => '9996'
}
```

This will create and entry in `flow-capture.conf` to listen on all interfaces on UDP port 9996 for flow data sent from 192.168.1.1.

##Usage

The basic usage of the module is listed above, and different examples will be explored below.

### Passing custom options to flow-capture
```
include flowtools
flowtools::device { 'device1':
  ip_address => '192.168.1.1',
  port       => '9996',
  options    => '-V 5'
}
```

### Specify a custom capture directory
```
class { 'flowtools':
  flow_dir => '/data/flows'
}
flowtools::device { 'device1':
  ip_address => '192.168.1.1',
  port       => '9996'
}
```

### Listening for all devices sending flow data to port 9996
```
include flowtools
flowtools::device { 'all':
  ip_address => '0.0.0.0',
  port       => '9996'
}
```

### Listening on a specific interface with custom options
```
include flowtools
flowtools::device { 'device1':
  ip_address => '192.168.1.1',
  port       => '9996',
  listen     => '192.168.1.33'
  options    => '-V 5'
}
```

### Just install flow-tools, don't start flow-capture
```
class { 'flowtools':
  capture => false,
}
```

##Reference
Classes:

* flowtools

Types:

* flowtools::device

Flow-Tools project:

* (Original) http://www.splintered.net/sw/flow-tools/
* (Active)   https://code.google.com/p/flow-tools/

##Limitations

This module only supports Debian and RedHat family operating systems. For Debian family systems, flow-tools must be availlable via apt. For RedHat systems, flow-tools is installed via a RPM of the latest version due to flow-tools not being available in the Epel, RPMForge or standard repos.

##Development

Feel free to make any additions to the module and issue a pull request. If you have a more elegant solution to some of the ways I've gone about things here, I'm certainly eager to hear about/implement them.

