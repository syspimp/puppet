class kickstart( $openstack_rootpass = '', $kickstartpass = '', $puppetmasterip = '', $puppetmaster = '' )
{
	include apache2
  $openstack_ssh_key = ssh_keygen('/etc/puppet/sshkeys/openstack')	
	$ksfiles = ["compute1-ans-file.txt","init.sh","ks-vmware4.cfg","ks-vmware5.cfg","preseed.cfg","ks-32bit.cfg","ks-64bit.cfg","ks-64bit-compute-node.cfg","puppetlabs.repo"]
	case $::operatingsystem {
    	  "ubuntu","debian": {
        	$service = "apache2"
                $apacheuser = "root"
                $apachegroup = "root"
          }
          default: {
            $service = "httpd"
                $apacheuser = "apache"
                $apachegroup = "apache"
          }
        }
	file { '/var/www/html/yum':
		ensure => directory,
		owner  => "$apacheuser",
		group => "$apachegroup",
		require => Service["$service"]
	}
	file { '/var/www/html/ksfiles':
		ensure => directory,
		owner  => "$apacheuser",
		group => "$apachegroup",
		require => Service["$service"]
	}
	file { ['/var/www/html/yum/centos6.2','/var/www/html/yum/centos6.2-disc2']:
		ensure => directory,
		require => File['/var/www/html/yum']
	}
	file { ['/var/www/html/ksfiles/vmware4','/var/www/html/ksfiles/vmware5']:
		ensure => directory,
		require => File['/var/www/html/ksfiles']
	}
    file { "/var/www/html/ksfiles/tfound-manage-puppet.sh":
        content => template("kickstart/tfound-manage-puppet.sh"),
        mode    => 755
    }
	file { "/var/www/html/ksfiles/tfound.repo":
		content	=>	template('tfound/tfound.repo.erb'),
		require	=>	File['/var/www/html/ksfiles']
	}
	kickstart::putksfiles { $ksfiles: }
}

define kickstart::putksfiles {
	file { "/var/www/html/ksfiles/${name}":
		content => template("kickstart/${name}"),
		require => File['/var/www/html/ksfiles']
	}
}
