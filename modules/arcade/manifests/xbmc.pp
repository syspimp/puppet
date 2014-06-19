# this setups up xbmc settings
class arcade::xbmc()
{
  if $::operatingsystem == 'windows'{
    file {
      "C:\\Users\\${arcade::arcadeuser}\\AppData\\Roaming\\XBMC\\userdata\\advancedsettings.xml":
      content => template('arcade/advancedsettings.xml.erb'),
      owner   => $arcade::arcadeuser,
      group   => 'Administrators',
      mode    => '0777',
    }
  }
}
