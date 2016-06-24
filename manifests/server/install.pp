class parse_platform::server::install {

  package { 'parse-server':
    provider => 'npm',
    require  => Class['nodejs']
  }
}
