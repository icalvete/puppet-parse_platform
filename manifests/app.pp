define  parse_platform::app (

  $app_name               = $name,
  $application_name       = $name,
  $application_id         = undef,
  $master_key             = undef,
  $database_uri           = "mongodb://localhost:27017/${name}",
  $port                   = 1337,
  $mount_path             = 'parse',
  $cloud_code             = false,
  $cloud_repository       = undef,
  $parse_root             = '/srv',
  $file_key               = undef,
  $javascript_key         = undef,
  $rest_key               = undef,
  $client_key             = undef,
  $public_url_schema      = 'http',
  $public_ip              = $::ipaddress,
  $public_port            = $port,
  $dashboard              = false,
  $dashboard_port         = 4040,
  $dashboard_user         = undef,
  $dashboard_pass         = undef,
  $dashboard_public_ip    = undef,
  $dashboard_public_port  = 1337,
  $aws_s3                 = false,
  $aws_s3_access_key      = undef,
  $aws_s3_secret_key      = undef,
  $aws_s3_bucket          = undef,
  $aws_s3_region          = 'eu-west-1',
  $aws_s3_bucket_prefix   = '',
  $aws_s3_direct_access   = false,
  $aws_s3_base_url        = '',
  $aws_s3_base_url_direct = false,
  $mailgun                = false,
  $mailgun_from_address   = undef,
  $mailgun_domain         = undef,
  $mailgun_api_key        = undef

) {

  if $dashboard_public_ip == undef {
    $dashboard_public_ip = $public_ip
  }

  $public_url           = "${public_url_schema}://${public_ip}:${public_port}/${mount_path}"
  $dashboard_public_url = "${public_url_schema}://${dashboard_public_ip}:${dashboard_public_port}/${mount_path}"
  $cloud_code_path      = "${parse_root}/${app_name}/cloud"

  validate_integer($port)
  validate_integer($dashboard_port)
  validate_integer($dashboard_public_port)
  validate_bool($cloud_code)
  validate_bool($dashboard)
  validate_bool($aws_s3)
  validate_bool($aws_s3_direct_access)
  validate_bool($aws_s3_base_url_direct)
  validate_bool($mailgun)

  if $cloud_code {

    if $cloud_repository != undef {

      vcsrepo { $cloud_code_path:
        ensure   => latest,
        provider => git,
        source   => $cloud_repository,
        revision => 'master',
      }
    } else {

      warning("############################################################")
      warning("### CLOUD CODE enabled.                                  ###")
      warning("### Put your code on ${parse_root}/${app_name}/cloud.                    ###")
      warning("############################################################")
    }
  }

  if $aws_s3 {

    if $aws_s3_access_key == undef {
      fail('AWS S3 enabled. $aws_s3_access_key can\'t be undef')
    }

    if $aws_s3_secret_key == undef {
      fail('AWS S3 enabled. $aws_s3_secret_key can\'t be undef')
    }

    if $aws_s3_bucket == undef {
      fail('AWS S3 enabled. $aws_s3_bucket can\'t be undef')
    }
  }

  if $mailgun {

    if $mailgun_from_address == undef {
      fail('Mailgun enabled. $mailgun_from_address can\'t be undef')
    }

    if $mailgun_domain == undef {
      fail('Mailgun enabled. $mailgun_domain can\'t be undef')
    }

    if $mailgun_api_key  == undef {
      fail('Mailgun enabled. $mailgun_api_key can\'t be undef')
    }
  }

  include parse_platform::server

  if $application_id == undef {
    fail('application_id must be a string')
  }

  if $master_key == undef {
    fail('master_key must be a string')
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
    path   => $cloud_code_path,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    require => File["parse_root_${app_name}"]
  }

  file{"parse_config_${app_name}":
    path    => "${parse_root}/${app_name}/config.json",
    content => template("${module_name}/config.json.erb"),
    mode    => '0644',
    require => File["parse_root_${app_name}"],
    notify  => Upstart::Job["parse-server_${app_name}"]
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
    sleep 10
    exec /usr/bin/parse-server ${parse_root}/${app_name}/config.json
    ",
    require             => Class['parse_platform::server::install']
  }

  if $dashboard {

    include parse_platform::dashboard

    if $dashboard_user == undef {
      fail('if $dashboard, $dashboard_user must be a string')
    }

    if $dashboard_pass == undef {
      fail('if $dashboard, $dashboard_pass must be a string')
    }

    if $javascript_key == undef {
      fail('if $dashboard, $javascript_key must be a string')
    }

    if $rest_key == undef {
      fail('if $dashboard, $rest_key must be a string')
    }

    file{"parse_dashboard_config_${app_name}":
      path    => "${parse_root}/${app_name}/dashboard_config.json",
      content => template("${module_name}/dashboard_config.json.erb"),
      mode    => '0644',
      require => File["parse_root_${app_name}"],
      notify  => Upstart::Job["parse-dashboard_${app_name}"]
    }

    upstart::job { "parse-dashboard_${app_name}":
      description         => "parse-dashboard_${$app_name}",
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
      sleep 12
      exec /usr/bin/parse-dashboard --port ${$dashboard_port} --config ${parse_root}/${app_name}/dashboard_config.json --allowInsecureHTTP
      ",
      require             => Class['parse_platform::dashboard::install']
    }
  }
}
