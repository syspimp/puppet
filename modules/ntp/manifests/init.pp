# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:
class ntp ( $ntpserver = '' ){
	$package = "ntp"
	case $operatingsystem {
		"ubuntu","debian": {
			$service = "ntp"
			file {
				"/etc/default/ntp":
					require => Package[$package],
					source  => [ "puppet:///modules/ntp/ntp.default" ],
					notify  => Exec["ntpdate $ntpserver"]
					;
			}
		}
		default: {
			$service = "ntpd"

			file {
				"/etc/sysconfig/ntpd":
					require => Package[$package],
          source  => [ "puppet:///modules/ntp/ntp.sysconfig" ],
					notify  => Exec["ntpdate $ntpserver"]
					;
			}
		}
	}

	package {
    $package: 
    ensure => installed;
  }

	service { 
    $service: 
      enable  => true,
      ensure  => running,
      notify  => Exec["service $service restart"]
  }

	file {
    "/etc/ntp.conf":
      require => Package["ntp"],
      content =>  template("ntp/ntp.conf"),
      notify  => Exec["ntpdate $ntpserver"]
      ;
    "/etc/localtime":
      ensure  =>  link,
      target  =>  "/usr/share/zoneinfo/EST5EDT"
      ;
	  "/var/run/ntp/":
		  ensure  => directory,
  		owner   => ntp,
	  	group   => ntp,
  		require => Package[$package],
	  	mode    => 755
	  	;
  	"/var/lib/ntp/":
	  	ensure  => directory,
		  owner   => ntp,
  		group   => ntp,
	  	require => Package[$package],
		  mode    => 755
		  ;
  	"/var/log/ntp/":
	  	ensure  => directory,
		  owner   => ntp,
  		group   => ntp,
	  	require => Package[$package],
		  mode    => 755
		  ;
  	"/etc/logrotate.d/ntpd":
	  	require => Package[$package],
		  source  => [ "puppet:///modules/ntp/ntp.logrotate" ]
  		;
  }

	exec { "service $service restart":
    command =>  "service $service stop ; ntpdate  $ntpserver ; service $service start",
    logoutput =>  true,
		refreshonly => true,
	}
	exec { "ntpdate $ntpserver":
		refreshonly => true,
    notify => Exec["service $service restart"]
	}
}
