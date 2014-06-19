# setups up the arcade machine
class arcade( $arcadeuser = hiera('robouser'),
              $arcadepass = hiera('robopass'),
              $samba_server = hiera('samba_server'),
              $domain = hiera('ad_domain'),
              $wallpaper = 'invader.jpg',
              $pathtomusic = 'N:/Music/Playlists/'
            )
{
  if $::operatingsystem == 'windows' {
    include arcade::profile
    include arcade::hyperspin
    include arcade::xbmc

# make sure you comment about above when running below, its faster
#    exec { 'take ownership':
#      command => 'C:\Windows\System32\takeown.exe /f C:\Hyperspin\Emulators\MESS\sta /R',
#      timeout => 0
#    }
#    exec { 'reset acls':
#      command => 'C:\Windows\System32\icacls.exe C:\Hyperspin\Emulators\MESS\sta /reset /T',
#      timeout => 0,
#      require => Exec['take ownership']
#    }
#    exec { 'take ownership1':
#      command => 'C:\Windows\System32\takeown.exe /f C:\Hyperspin\Emulators\MESS\nvram /R',
#      timeout => 0
#    }
#    exec { 'reset acls1':
#      command => 'C:\Windows\System32\icacls.exe C:\Hyperspin\Emulators\MESS\nvram /reset /T',
#      timeout => 0,
#      require => Exec['take ownership1']
#    }
  }
}
