class arcade::profile() 
{
  if $operatingsystem == "windows" {

    file { 'C:\Arcade':
      ensure => directory,
      owner => "$arcade::arcadeuser",
      group => "Administrators",
      mode => '0777',
      recurse => true
    }
    file { 'C:\Arcade\locks':
      ensure => directory,
      owner => "$arcade::arcadeuser",
      group => "Administrators",
      mode => '0777',
      require => File['C:\Arcade']
    }
    file { 'C:\Arcade\registry':
      ensure => directory,
      owner => "$arcade::arcadeuser",
      group => "Administrators",
      mode => '0777',
      require => File['C:\Arcade']
    }
    file { 'C:\Arcade\scripts':
      ensure => directory,
      owner => "$arcade::arcadeuser",
      group => "Administrators",
      mode => '0777',
      require => File['C:\Arcade']
    }
    file { 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\mountdrives.cmd':
      content => template("arcade/mountdrives.cmd.erb"),
      owner => "$arcade::arcadeuser",
      group => "Administrators",
      mode => '0777',
    }
    file { 'C:\Arcade\scripts\autologin.cmd':
      content => template("arcade/autologin.cmd.erb"),
      owner => "$arcade::arcadeuser",
      group => "Administrators",
      mode => '0777',
      require => File['C:\Arcade\scripts']
    }
    file { 'C:\Arcade\scripts\profile.cmd':
      content => template("arcade/profile.cmd.erb"),
      owner => "$arcade::arcadeuser",
      group => "Administrators",
      mode => '0777',
      require => File['C:\Arcade\scripts']
    }
    file { 'C:\Arcade\registry\autologin.reg':
      content => template("arcade/autologin.reg.erb"),
      owner => "$arcade::arcadeuser",
      group => "Administrators",
      mode => '0777',
      require => File['C:\Arcade\registry']
    }
    file { 'C:\Arcade\registry\profile.reg':
      content => template("arcade/profile.reg.erb"),
      owner => "$arcade::arcadeuser",
      group => "Administrators",
      mode => '0777',
      require => File['C:\Arcade\registry']
    }
    file { 'C:\Arcade\pics':
      source => 'S:\arcade\pics',
      ensure => directory,
      recurse => true,
      owner => "$arcade::arcadeuser",
      group => "Administrators",
      mode => '0777',
      require => File['C:\Arcade']
    }
    exec { 'arcade-autologin':
      command => 'C:\Arcade\scripts\autologin.cmd',
      creates => 'C:\Arcade\locks\autologin.lock',
      require => [File['C:\Arcade\scripts\autologin.cmd'],File['C:\Arcade\registry\autologin.reg'],File['C:\Arcade\locks']]
    }
    exec { 'arcade-profile':
      command => 'C:\Arcade\scripts\profile.cmd',
      creates => 'C:\Arcade\locks\profile.lock',
      require => [File['C:\Arcade\scripts\autologin.cmd'],File['C:\Arcade\registry\profile.reg'],File['C:\Arcade\locks']]
    }
  }
}
