class parse_platform::install {

  package { 'parse-server':
    provider => 'npm',
    require  => Class['nodejs']
  }
}
