class parse_platform (

  $application_id = undef,
  $master_key     = undef

) inherits parse_platform::params {

  if $application_id == undef {
    fail('application_id must be a string')
  }
  
  if $master_key == undef {
    fail('master_key must be a string')
  }

  anchor {'parse_platform::begin':
    before => Class['parse_platform::install']
  }
  class {'parse_platform::install':
    require => Anchor['parse_platform::begin']
  }
  class {'parse_platform::config':
    require => Class['parse_platform::install']
  }
  class {'parse_platform::service':
    subscribe => Class['parse_platform::config']
  }
  anchor {'parse_platform::end':
    require => Class['parse_platform::service']
  }
}
