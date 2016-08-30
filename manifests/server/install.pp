class parse_platform::server::install {

  package { 'parse-server':
    ensure   => '2.2.18',
    provider => 'npm',
    require  => Class['nodejs']
  }

  package { 'bcrypt':
    ensure   => '0.8.7',
    provider => 'npm',
    require  => Package['parse-server']
  }
}
