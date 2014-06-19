# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:
class tfound (  $puppetmasterip = hiera('puppetmasterip'), 
                $puppetmaster = hiera('puppetmaster'),
                $puppetmaster_alt_names = hiera('puppetmaster_alt_names'),
                $datacenter = datacenter($ipaddress) ) 
{
  if 'puppet' in $fqdn {
    $repoip = hiera('repoip')
    service { "httpd": ensure => running, enable => true; }
    host { "$fqdn": ip => "$ipaddress"; }
  } else {
	  $repoip=$puppetmasterip
	  host { "$puppetmaster":
      ip => "$puppetmasterip",
      host_aliases => 'puppet',
    }
  }
  $env = $environment ? {
    /(?i-mx:development)/   => 'dev',
    /(?i-mx:qa)/            => 'qa',
    /(?i-mx:production)/    => 'prod',
    /(?i-mx:physical)/      => 'prod',
    /(?i-mx:stage)/         => 'stage',
    /(?i-mx:openstack)/     => 'prod',
    default                 => 'dev'
  }                                                      
  case $operatingsystem {
    "ubuntu","debian": {
      service { "puppet": ensure => stopped, enable => false; }
      package {
        "logcheck": ensure => purged;
        "mpt-status": ensure => purged;
      }
      file {
        "/etc/default/puppet":
          source => [ "puppet:///modules/tfound/puppet.default" ];
      }
    }
	  "Fedora": {
      package {
	      "logwatch": ensure => absent;
	      "yum-utils": ensure => installed;
	      "wget": ensure => installed;
	      "vim-enhanced": ensure => installed;
	      "screen":       ensure => installed;
	      "mc":           ensure => installed;
	      "telnet":           ensure => installed;
	      "python-boto":  ensure => installed;
	      "python-ldap":  ensure => installed;
	      "fortune-mod":  ensure  => installed;
	      "sysstat":  ensure  => installed;
	      "redhat-lsb":  ensure  => installed;
	      "setuptool":  ensure  => installed;
	      "authconfig":  ensure  => installed;
	    }
			service {
			  "cups": ensure => stopped, enable => false;
			  "cpuspeed": enable => false;
			  "iptables": enable => false;
			  "ip6tables": enable => false;
	      "puppet": ensure => stopped, enable => false;
			}
		  file {
	      "/etc/yum.repos.d/tfound.repo":
	        content  => template("tfound/tfound.repo.erb"),
	        ;
	      "/etc/yum.conf":
	        content => template("tfound/yum.conf.erb"),
	        ;
	    }
		}
    "Windows": { 
      include tfound::windows
    }
    default: {
      package {
	      "logwatch": ensure => absent;
	      "yum-utils": ensure => installed;
	      "vim-enhanced": ensure => installed;
	      "epel-release": ensure => installed;
	      "puppetlabs-release":   ensure => installed;
	      #"screen":       ensure => installed;
	      "mc":           ensure => installed;
	      "telnet":           ensure => installed;
	      "python-boto":  ensure => installed;
	      "fortune-mod":  ensure  => installed;
	      "sysstat":  ensure  => installed;
      }
      service {
        "cups": ensure => stopped, enable => false;
        "cpuspeed": enable => false;
        "iptables": enable => false;
        "ip6tables": enable => false;
      }
      case $lsbmajdistrelease {
        "6": {
          package {
            "yum-plugin-downloadonly": ensure => installed;
            "redhat-lsb": ensure => installed;
          }
        }
        default: {
          package {
            "yum-downloadonly": ensure => installed;
          }
        }
      }
      file {
        "/etc/yum.repos.d/tfound.repo":
          content  => template("tfound/tfound.repo.erb"),
        ;
        "/etc/yum.conf":
          content => template("tfound/yum.conf.erb"),
        ;
      }
    }
  }
  if $operatingsystem != "Windows" {
    file { "/etc/cron.d/puppet.cron":
      content => template("tfound/puppet.cron"),
      ;
    }
    file {"/etc/logrotate.d/syslog":
      path => "/etc/logrotate.d/syslog",
      source => "puppet:///modules/tfound/syslog.logrotate",
      replace => true,
      owner => root,
      group => root,
      mode => 644,
    }
    if $datacenter == "ec2" {
      file { "/etc/resolv.conf":
        content =>  template("tfound/ec2-resolv.conf.erb")
      }
    }
    file {
      "/etc/puppet/puppet.conf":
        content => template("tfound/puppet.erb")
        ;
      "/usr/local/tfound":
        ensure  => directory,
        ;
      "/etc/profile.d/history.sh":
        source  => [ "puppet:///modules/tfound/history.sh" ],
        mode    => 755
        ;
	    }  
    $root_ssh_key = ssh_keygen('/etc/puppet/sshkeys/id_rsa')
    $openstack_ssh_key = ssh_keygen('/etc/puppet/sshkeys/openstack')
    $ec2_ssh_key = ssh_keygen('/etc/puppet/sshkeys/tfound-ec2')
    file {
      "/etc/setprompt.sh":
      content => template("tfound/setprompt.erb"),
      mode => 755
      ;
      "/etc/bashrc":
      content => template("tfound/bashrc"),
      mode => 644
      ;
      "/root/.vimrc":
      content => template("tfound/vimrc"),
      mode => 644
      ;
      "/root/.bashrc":
      content => template("tfound/rootbashrc"),
      mode => 644
      ;
      "/root/.vim":
      ensure  => directory
      ;
      "/root/.vim/skel":
      ensure  => directory,
      require => File["/root/.vim"]
      ;
      "/root/.vim/skel/tmpl.sh":
      mode  => 755,
      content => template("tfound/tmpl.sh"),
      require => File["/root/.vim/skel"]
      ;
      "/root/.screenrc":
      content => template("tfound/screenrc"),
      mode => 644
      ;
      "/root/.ssh":
      ensure	=> directory,
      mode	=> 700
      ;
      "/root/.ssh/config":
      name => "/root/.ssh/config",
      path => "/root/.ssh/config",
      content => template("tfound/sshconfig"),
      mode => 600,
	    require => File['/root/.ssh']
      ;
      "/root/.ssh/tfound-ec2":
      content => ${ec2_ssh_key[0]},
      mode    => 600,
      require => File['/root/.ssh']
      ;
      "/root/.ssh/tfound-ec2.pub":
      content => ${ec2_ssh_key[1]},
      mode => 600,
      require => File['/root/.ssh']
      ;
      "/root/.ssh/id_rsa":
      content => ${root_ssh_key[0]},
      mode    => 600,
      require => File['/root/.ssh']
      ;
      "/root/.ssh/id_rsa.pub":
      content => ${root_ssh_key[1]},
      mode    => 600,
      require => File['/root/.ssh']
      ;
      "/root/.ssh/openstack":
      content => ${openstack_ssh_key[0]},
      mode    => 600,
      require => File['/root/.ssh']
      ;
      "/root/.ssh/openstack.pub":
      content => ${openstack_ssh_key[1]},
      mode    => 600,
      require => File['/root/.ssh']
      ;
      "/opt/tfound":
      ensure  => directory
      ;
      "/opt/tfound/bin":
      ensure  => directory,
      require => File["/opt/tfound"]
      ;
      "/opt/tfound/bin/tfound-manage-puppet.sh":
      content => template("kickstart/tfound-manage-puppet.sh"),
      mode => 755
      ;
    }
  }
}
