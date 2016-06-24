class parse_platform::server () inherits parse_platform::params {

  anchor {'parse_platform::server::begin':
    before => Class['parse_platform::server::install']
  }
  class {'parse_platform::server::install':
    require => Anchor['parse_platform::server::begin']
  }
  class {'parse_platform::server::config':
    require => Class['parse_platform::server::install']
  }
  class {'parse_platform::server::service':
    subscribe => Class['parse_platform::server::config']
  }
  anchor {'parse_platform::server::end':
    require => Class['parse_platform::server::service']
  }
}
