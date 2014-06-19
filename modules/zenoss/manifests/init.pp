# Module: zenoss
#
# Maintains configuration for SNMP monitoring through Zenoss
# see http://reductivelabs.com/trac/puppet/wiki/ExportedResources

# Class: zenoss
#
# Zenoss
class zenoss ( $user = hiera('zenossuser'), $pass = hiera('zenosspass'), $host = hiera('zenosshost'), $port = hiera('zenossport'), $syslog = hiera('syslog'), $zenosssnmp = hiera('snmpcommunity'), $zenossenabled = hiera('zenoss::zenossenabled','client') ){
  $zenossuri = "http://${user}:${pass}@${host}:${port}/zport/dmd"
  if ( $zenossenabled == 'server' ) {
    class { "zenoss::server": stage => 'runtime' }
  } else {
    zenoss::client{"$fqdn": zenossuri => $zenossuri }
  }
}

define zenoss::nodeless ( $url = 'none' ) {
    if ( $title == 'client' ) {
        zenoss::client{"$fqdn": zenossuri => $url }
    } else {
        class { "zenoss::server": stage => 'runtime' }
    }
}
