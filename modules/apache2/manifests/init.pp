# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:
class apache2 {
  case $::operatingsystem {
    'ubuntu','debian': {
      $service = 'apache2'
      $confdir = '/etc/apache2/sites-enabled/'
      $apacheuser = 'root'
      $apachegroup = 'adm'
    }
    default: {
      $service = 'httpd'
      $confdir = '/etc/httpd/conf.d/'
      $apacheuser = 'root'
      $apachegroup = 'root'
    }
  }

  package { $service:
    ensure => installed;
  }
  service { $service:
    ensure  =>  running,
    require =>  Package[$service],
    enable  =>  true;
  }

  exec { "service ${service} reload":
          refreshonly => true,
  }
  file { "/var/log/${service}/vhost-logs":
    ensure  =>  'directory',
    owner   =>  $apacheuser,
    group   =>  $apachegroup,
    mode    =>  '0777',
  }
  file { "${confdir}/00${::hostname}.conf":
      content =>  template('apache2/00hostname.conf.erb'),
      notify  =>  Service[$service]
  }
}
