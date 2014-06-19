class base {
  if $operatingsystem != "Windows" {
    include motd, aliases, ntp, snmp, user
  }
  include stdlib
  class { "tfound":
	  stage => 'runtime'
  }
}
