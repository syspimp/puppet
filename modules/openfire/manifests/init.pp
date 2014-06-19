class openfire()
{
	package { ["openfire","/lib/ld-linux.so.2"]:
		ensure => latest,
	}

	service { "openfire":
                ensure => running,
                enabled => true
	}
	
}
