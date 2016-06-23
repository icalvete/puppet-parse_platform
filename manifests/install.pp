class parse_platform::install {

  exec { 'parseserver_install':
    command  => 'npm install -g parse-server',
    user     => 'root',
    provider => 'shell',
    unless   => '/usr/bin/test -d /usr/lib/node_modules/parse-server'
  }
}
