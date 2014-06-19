define tfound::windows::fix_permissions ( $path = 'None' )
{
  if $path != 'None'
  {
    exec { 'take ownership now':
      command => 'C:\Windows\System32\takeown.exe /f "$path" /R',
    }
    exec { 'reset acls now':
      command => 'C:\Windows\System32\icacls.exe "$path" /reset /T',
      require => Exec['take ownership now']
    }
  }
  else
  {
    notify{"No path passed to fix_permissions, nothing to fix": }
  }
}
