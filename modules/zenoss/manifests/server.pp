# Module: zenoss::server
#
# Maintains configuration for SNMP monitoring through Zenoss
# see http://reductivelabs.com/trac/puppet/wiki/ExportedResources

# Add this class to the host running the zenoss server
class zenoss::server {

  Zenoss_host <<| |>>

  # Zenoss user ssh key:
  $zenoss_user_ssh_key = ssh_keygen('/etc/puppet/sshkeys/zenoss_user')

  file{
    '/home/zenoss/.ssh':
      ensure  => directory,
      owner   => 'zenoss',
      group   => 'zenoss',
      mode    => '0700';

    '/home/zenoss/.ssh/id_dsa':
      content => "${zenoss_user_ssh_key[0]}",
      owner   => 'zenoss',
      group   => 'zenoss',
      mode    => '0600';

    '/home/zenoss/.ssh/id_dsa.pub':
      content => "${zenoss_user_ssh_key[1]}",
      owner   => 'zenoss',
      group   => 'zenoss',
      mode    => '0644';
  }

  # Export authorized key, collected in zenoss::client
  $zenoss_user_public_key   = split($zenoss_user_ssh_key[1],' ')

  @@zenoss::ssh_authorized_key { "zenoss@${::fqdn}":
    user  => 'zenoss',
    type  => $zenoss_user_public_key[0],
    key   => $zenoss_user_public_key[1],
    tag   => 'zenoss-key',
  }

  # install expect package for check_ssl_cert
  package{'expect':
    ensure => present,
  }

  # install fping package for ZenPacks.BlakeDrager.fping
  package{'fping':
    ensure => present,
  }
}
