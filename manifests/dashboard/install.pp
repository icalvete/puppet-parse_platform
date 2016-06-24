class parse_platform::dashboard::install {

  package { 'parse-dashboard':
    provider => 'npm',
    require  => Class['nodejs']
  }
}
