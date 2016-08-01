class parse_platform::server::install {

  package { 'parse-server':
    ensure   => '2.2.16',
    provider => 'npm',
    require  => Class['nodejs']
  }
}
