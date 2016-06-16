# puppet-parse_platform

Puppet manifest to install and configure a Parse Platform server

See [parse site](https://parse.com/)

* https://github.com/icalvete/puppet-nodejs
* https://github.com/Spantree/puppet-upstart

##Example:


```puppet
node 'ubuntu01.smartpurposes.net' inherits test_defaults {
  include roles::puppet_agent
  include nodejs

  class {'parse_platform':
    application_id => 'your_id',
    master_key     => 'your_key',
  }
	        
```

##Authors:

Israel Calvete Talavera <icalvete@gmail.com>
