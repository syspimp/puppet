class buildserver()
{
#	include kickstart
	package { ['gcc','rpm-build','autoconf','subversion']:
        ensure => present,
 #       before => File['/root/.bashrc'],
    }

	file { '/root/buildroot':
		ensure => directory,
		owner  => 'root',
		group => 'root'
	}
#	file { '/root/.bashrc':
#		content => template("buildserver/user-bashrc"),
#		owner  => 'root',
#		group => 'root',
#		mode => '0644'
#	}

	file { ['/root/buildroot/SPECS','/root/buildroot/SOURCES','/root/buildroot/RPMS','/root/buildroot/SRPMS','/root/buildroot/BUILD','/root/buildroot/BUILDROOT']:
		ensure => directory,
		require => File['/root/buildroot']
	}
	file { '/root/.rpmmacros':
		content => template("buildserver/rpmmacros")
	}
    if fact_enabled("nodeless_buildserver") {
        buildserver::nodeless {"$nodeless_buildserver":}
    }
}
define buildserver::nodeless {
    if ( $title != 'true' ) {
        include "buildserver::${title}"
    }
}
