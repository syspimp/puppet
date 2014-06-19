# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:
class snmp ( $snmpcommunity = hiera('snmpcommunity'), $root_alias = hiera('root_alias') ) {
	$service = "snmpd"
	case $operatingsystem {
		"ubuntu","debian": {
			$package = "snmpd"
			file {
				"/etc/default/snmpd":
					require => Package[$package],
					source  => [ "puppet:///modules/snmp/snmpd.default" ],
					notify  => Exec["service snmpd restart"]
					;
				"/etc/init.d/snmpd":
					require => Package[$package],
					source  => [ "puppet:///modules/snmp/snmpd.init" ],
					mode    => 755,
					notify  => Exec["service snmpd restart"]
					;
			}
		}
		default: {
			$package = ["net-snmp", "net-snmp-devel"]
			file {
				"/etc/sysconfig/snmpd.options":
					require => Package[$package],
					source  => [ "puppet:///modules/snmp/snmpd.sysconfig" ],
					notify  => Exec["service $service restart"]
					;
			}
		}
	}
	package { $package: ensure => installed; }
	service { $service: ensure => running, enable => true; }

	file {
		"/etc/logrotate.d/snmpd":
			require => Package[$package],
			source  => [ "puppet:///modules/snmp/snmpd.logrotate" ]
			;
		"/etc/snmp/snmpd.conf":
			content => template("snmp/snmpd.erb"),
            notify => Exec["service snmpd restart"]
			;
		
	}

	exec {
		"service $service restart":
			refreshonly => true;
	}
}
