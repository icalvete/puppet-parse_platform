define  parse_platform::app (

  $app_name         = $name,
  $application_id   = undef,
  $master_key       = undef,
  $port             = 1337,
  $cloud_code       = false,
  $database_URI     = undef,
  $cloud_repository = undef,
  $parse_root       = undef
) {

  if $cloud_code {
    warning("cloud_code enabled.")
    warning("Put your code on $ ${parse_root }/${app_name}/cloud.")
  }

  include parse_platform

  if $app_name == undef {
    fail('app_name must be a string')
  }

  if $application_id == undef {
    fail('application_id must be a string')
  }

  if $master_key == undef {
    fail('master_key must be a string')
  }

  validate_integer($port)

  if $database_URI == undef {
    warning('databaseURI not specified, falling back to localhost.')
  }

  validate_absolute_path($parse_root)

  file { "parse_root_${app_name}":
    ensure => directory,
    path   => "${parse_root}/${app_name}",
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { "parse_cloud_${app_name}":
    ensure => directory,
    path   => "${parse_root}/${app_name}/cloud",
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    require => File["parse_root_${app_name}"]
  }

  file{"parse_config_${app_name}":
    path    => "${parse_root}/${app_name}/config.json",
    content => template("${module_name}/config.json.erb"),
    mode    => '0644',
    require => File["parse_root_${app_name}"]
  }

  upstart::job { "parse-server_${app_name}":
    description         => "parse-server_${$app_name}",
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
    exec /usr/lib/node_modules/parse-server/bin/parse-server ${parse_root}/${app_name}/config.json
    ",
  }
}
