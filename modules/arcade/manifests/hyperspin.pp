# this setups up hyperspin
class arcade::hyperspin()
{
  if $::operatingsystem == 'windows' {
    $dirs = [
      'C:\Hyperspin\Data',
      'C:\Hyperspin\Databases',
      'C:\Hyperspin\Don\'s HyperSpin Tools',
      'C:\Hyperspin\Emulators',
      'C:\Hyperspin\HyperSync Cloud',
      'C:\Hyperspin\HyperTheme',
      'C:\Hyperspin\Lib',
      'C:\Hyperspin\Media',
      'C:\Hyperspin\Module Extensions',
      'C:\Hyperspin\Modules',
      'C:\Hyperspin\Profiles',
      'C:\Hyperspin\Settings',
      'C:\Hyperspin\-10'
    ]

    file { 'C:\Hyperspin':
      ensure  => directory,
      owner   => $arcade::arcadeuser,
      group   => 'Administrators',
      mode    => '0777',
    }

    arcade::hyperdirs { $dirs: }
  }
}
