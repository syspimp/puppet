class red5(	$red5version = '1.0.0')
{
	package { ["red5","jdk"]:
		ensure => latest,
	}

	file { "/opt/red5":
		ensure => link,
		target => "/opt/red5-$red5version",
		require => Package["red5"]
	}
	file { "/opt/red5/start-red5.sh":
		content => template("red5/start-red5.sh"),
		mode	=> 755,
		require => Package["red5"]
	}
	exec { "/opt/red5/start-red5.sh start":
		unless => "/opt/red5/start-red5.sh status",
		require => [Package["red5"],File["/opt/red5/start-red5.sh"]]
	}
	
}
