class parse_platform () inherits parse_platform::params {

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
