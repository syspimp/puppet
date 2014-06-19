class tfound::windows ( 
                       $samba_server  = hiera('samba_server'),
                       $syslog        = hiera('syslog'),
                       $snmpcommunity = hiera('snmpcommunity'),
                       $root_alias    = hiera('root_alias'),
                       $robouser    = hiera('robouser'),
                       $puppetmaster    = hiera('puppetmaster'),
                       $datacenter    = datacenter($ipaddress),
                       )
{
  notify{
    "Setting up Taylor Foundation Windows PC's":
  }
  service { 
    "puppet": ensure => running, enable => true; 
    "snmp": ensure => running, enable => true; 
  }
  file { 'C:\Tfound':
    ensure => directory,
    owner => "Administrator",
    group => "Administrators",
    mode => '0777'
  }
  file { 'C:\Tfound\scripts':
    ensure => directory,
    owner => "Administrator",
    group => "Administrators",
    mode => '0777',
    require => File['C:\Tfound']
  }
  file { 'C:\Tfound\run':
    ensure => directory,
    owner => "Administrator",
    group => "Administrators",
    mode => '0777',
    require => File['C:\Tfound']
  }
  file { 'C:\ProgramData\PuppetLabs\puppet\etc\puppet.conf':
    content => template("tfound/windows-puppet.conf.erb"),
    owner => "Administrator",
    group => "Administrators",
    mode => '0774',
    notify  =>  Service["puppet"]
  }
  file { 'C:\Tfound\scripts\mountdrives.cmd':
    content => template("tfound/mountdrives.cmd.erb"),
    owner => "Administrator",
    group => "Administrators",
    mode => '0777',
    require => File['C:\Tfound\scripts']
  }
  exec { 'mountdrives':
    command => 'C:\Tfound\scripts\mountdrives.cmd',
    require => File['C:\Tfound\scripts\mountdrives.cmd']
  }
  file { 'C:\Tfound\scripts\setup-snmp.cmd':
    content => template("tfound/setup-snmp.cmd.erb"),
    owner => "$robouser",
    group => "Administrators",
    mode => '0777',
    require => File['C:\Tfound\scripts']
  }
  file { 'C:\Tfound\scripts\setup-snmp.reg':
    content => template("tfound/setup-snmp.reg.erb"),
    owner => "$robouser",
    group => "Administrators",
    mode => '0777',
    require => File['C:\Tfound\scripts']
  }
  exec { 'setting up snmp':
    command => 'C:\Tfound\scripts\setup-snmp.cmd',
    require => [File['C:\Tfound\scripts\setup-snmp.cmd'],File['C:\Tfound\scripts\setup-snmp.reg']]
  }
}

