# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:
define apache2::vhost($port,
                      $docroot,
                      $ssl,
                      $priority,
                      $template='apache2/default_vhost.erb',
                      $serveraliases = '' )
{
  case $::operatingsystem {
    'ubuntu','debian': {
      $webconfdir = '/etc/apache2/sites-enabled'
    }
    default: {
      $webconfdir = '/etc/httpd/conf.d'
    }
  }

  file {
    "${webconfdir}/${priority}-${name}.conf":
    content => template($template),
  }
}
