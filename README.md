# puppet-parse_platform

Puppet manifest to install and configure a Parse Platform server

[![Build Status](https://secure.travis-ci.org/icalvete/puppet-parse_platform.png)](http://travis-ci.org/icalvete/puppet-parse_platform)

See [parse site](https://parse.com/)

* https://github.com/icalvete/puppet-nodejs
* https://github.com/Spantree/puppet-upstart

##Example:

Two app running on one server. 

The second one with cloud code enabled. 

**You should put cloud code on /srv/app2/cloud.**

```puppet

node 'ubuntu01.smartpurposes.net' inherits test_defaults {
  include roles::puppet_agent
  include nodejs

  parse_platform::app {'app1':
    application_id => '111',
    master_key     => '111'
  }

  parse_platform::app {'app2':
    application_id => '222',
    master_key     => '222',
    port           => 1338,
    cloud_code     => true
  }

	        
```

##Authors:

Israel Calvete Talavera <icalvete@gmail.com>
