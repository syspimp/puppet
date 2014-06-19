# Module: zenoss::client
#
# Maintains configuration for SNMP monitoring through Zenoss
# see http://reductivelabs.com/trac/puppet/wiki/ExportedResources

define zenoss::client(
  $zenossuri,
  $ensure           = 'present',
  $ip               = $::ipaddress,
  $zenosstype       = 'absent',
  $zenosscollector  = 'localhost',
  $serialnumber     = 'unknown',
  $grouppath        = ['/new'],
  $systempath       = ['/new'],
  $zenosspass       = hiera('zenosspass'),
  $zenossuser       = hiera('zenossuser'),
  $zenosssnmp       = hiera('snmpcommunity')
) {
  if $operatingsystem != "Windows" {
    service { "rsyslog": ensure => running; }
    file { "/etc/rsyslog.d/zenoss.conf":
          content => template("zenoss/rsyslog.zenoss.conf.erb"),
          notify  => Service["rsyslog"]
    }
    Zenoss::Ssh_authorized_key <<| tag == 'zenoss-key' |>>
  }
  $state = $environment ? {
  		/(?i-mx:development)/ => '300',
  		/(?i-mx:qa)/          => '400',
  		/(?i-mx:production)/  => '1000',
  		/(?i-mx:physical)/  => '1000',
  		/(?i-mx:stage)/       => '500',
  		/(?i-mx:openstack)/       => '1000',
  		default               => '300'
  }
  # define zenosstype
  if $zenosstype == 'absent' {
    if $::virtual == 'xen0' {
      $real_zenosstype = 'xen0'
    } else {
      $real_zenosstype = $::kernel
    }
  }
  else {
    $real_zenosstype = $zenosstype
  }

  # exports these attributes to the puppetmaster database as a zenoss_host type
  @@zenoss_host { $::fqdn:
    ensure          => $ensure,
    alias           => $::hostname,
    ip              => $ip,
    state           => $state,
    zenosspass           => $zenosspass,
    zenossuser           => $zenossuser,
    zenosstype      => $real_zenosstype,
    zenosscollector => $zenosscollector,
    serialnumber    => $serialnumber,
    grouppath       => $grouppath,
    systempath      => $systempath,
    zenossuri       => $zenossuri,
    zenosssnmp      => $zenosssnmp
  }
}
