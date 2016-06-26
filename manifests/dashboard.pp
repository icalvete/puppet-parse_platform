class parse_platform::dashboard () inherits parse_platform::params {

  anchor {'parse_platform::dashboard::begin':
    before => Class['parse_platform::dashboard::install']
  }
  class {'parse_platform::dashboard::install':
    require => Anchor['parse_platform::dashboard::begin']
  }
  class {'parse_platform::dashboard::config':
    require => Class['parse_platform::dashboard::install']
  }
  class {'parse_platform::dashboard::service':
    subscribe => Class['parse_platform::dashboard::config']
  }
  anchor {'parse_platform::dashboard::end':
    require => Class['parse_platform::dashboard::service']
  }
}
