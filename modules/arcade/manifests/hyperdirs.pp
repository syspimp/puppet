# this sets all hyperspin directory's permissions
define arcade::hyperdirs
{
    file { $name:
      ensure  => directory,
      owner   => $arcade::arcadeuser,
      group   => 'Administrators',
      mode    => '0777',
      recurse => true,
      require => File['C:\Hyperspin']
    }
}
