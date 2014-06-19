class miner( $mineruser = hiera('robouser'), 
              $minerpass = hiera('robopass'), 
              $minerpath = hiera('minerpath'), 
              $minerprog = hiera('minerprog'), 
              $domain = hiera('ad_domain') ) 
{
  if $operatingsystem == "windows" {
    scheduled_task { 'Reboot Handler 0':
      ensure    => present,
      enabled   => false,
      command   => 'C:\Windows\System32\shutdown.exe',
      arguments => '-t 0 -r -f',
      trigger   => {
        schedule   => daily,
        start_time => '00:01',      # Must be specified
      }
    }
    scheduled_task { 'Reboot Handler 6':
      ensure    => present,
      enabled   => false,
      command   => 'C:\Windows\System32\shutdown.exe',
      arguments => '-t 0 -r -f',
      trigger   => {
        schedule   => daily,
        start_time => '06:01',      # Must be specified
      }
    }
    scheduled_task { 'Reboot Handler 12':
      ensure    => present,
      enabled   => false,
      command   => 'C:\Windows\System32\shutdown.exe',
      arguments => '-t 0 -r -f',
      trigger   => {
        schedule   => daily,
        start_time => '12:01',      # Must be specified
      }
    }
    scheduled_task { 'Reboot Handler 18':
      ensure    => present,
      enabled   => false,
      command   => 'C:\Windows\System32\shutdown.exe',
      arguments => '-t 0 -r -f',
      trigger   => {
        schedule   => daily,
        start_time => '18:01',      # Must be specified
      }
    }
    file { "${minerpath}":
      ensure => directory,
      owner => "$mineruser",
      group => "Administrators",
      mode => '0777',
      recurse => true
    }
    file { "${minerpath}\${minerprog}":
      ensure => directory,
      owner => "$mineruser",
      group => "Administrators",
      mode => '0777'
    }
    file { 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\startup-call-the-miner.lnk':
      owner => "$mineruser",
      group => "Administrators",
      mode => '0777',
      source => "puppet:///modules/miner/startup-call-the-miner.lnk",
    }
    file { 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\startup-mining-runfirst.lnk':
      owner => "$mineruser",
      group => "Administrators",
      mode => '0777',
      source => "puppet:///modules/miner/startup-mining-runfirst.lnk",
    }
    file { "${minerpath}\autologin.cmd":
      content => template("miner/autologin.cmd.erb"),
      owner => "$mineruser",
      group => "Administrators",
      mode => '0777',
      require => File["${minerpath}"]
    }
    file { "${minerpath}\autologin.reg":
      content => template("miner/autologin.reg.erb"),
      owner => "$mineruser",
      group => "Administrators",
      mode => '0777',
      require => File["${minerpath}"]
    }
    file { "${minerpath}\call-the-miner.cmd":
      content => template("miner/call-the-miner.cmd.erb"),
      owner => "$mineruser",
      group => "Administrators",
      mode => '0777',
      require => File["${minerpath}"]
    }
    file { "${minerpath}\start-mining-multipool.cmd":
      content => template("miner/start-mining-multipool.cmd.erb"),
      owner => "$mineruser",
      group => "Administrators",
      mode => '0777',
      require => File["${minerpath}"]
    }
    exec { 'miner-autologin':
      command => "C:\${minerpath}\autologin.cmd",
      require => [File["${minerpath}\autologin.cmd"],File["${minerpath}\autologin.reg"]]
    }
  }
}
