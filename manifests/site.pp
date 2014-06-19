# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:

$datacenter = datacenter($ipaddress)
$custom_scripts_path = '/opt/mycompany/bin'

if $osfamily == 'windows'
{
  File { source_permissions => ignore }
} 
else 
{
  File {
    owner   => root,
    group   => root,
    mode    => 444,
    ensure  => file,
    backup => false
  }
}

Cron {
	environment => 'PATH=/usr/bin:/usr/sbin:/bin:/sbin'
}

Exec {
	path => "/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:$custom_scripts_path"
}

Service {
        hasrestart => true,
        hasstatus => true,
}

hiera_include('classes')
