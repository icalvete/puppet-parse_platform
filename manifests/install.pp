class parse_platform::install {

  exec { 'parseserver_install':
    command  => 'npm install -g parse-server',
    user     => 'root',
    provider => 'shell',
    unless   => '/usr/bin/test -d /usr/lib/node_modules/parse-server'
  }

  upstart::job { 'parse-server':
    description         => 'parse-server',
    start_on            => 'runlevel [2345]',
    stop_on             => 'runlevel [016]',
    respawn             => true,
    respawn_limit       => '5 10',
    chdir               => '/tmp',
    env                 => {
      'PATH'            => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      'APPLICATION_ENV' => $environment
    },
    script              => "
    exec /usr/lib/node_modules/parse-server/bin/parse-server --appId ${parse_platform::application_id} --masterKey ${parse_platform::master_key}
    ",
  }

}
