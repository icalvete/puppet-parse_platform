class parse_platform::dashboard::install {

  package { 'parse-dashboard':
    ensure   => '1.0.14',
    provider => 'npm',
    require  => Class['nodejs']
  }
}
