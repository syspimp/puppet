# wrapper to have some defaults.
define zenoss::ssh_authorized_key(
    $ensure = 'present',
    $type = 'ssh-dss',
    $key = 'absent',
    $user = $name,
    $target = undef,
    $options = 'absent'
){

  if ($ensure=='present') and ($key=='absent') {
    fail("You have to set \$key for Zenoss::Ssh_authorized_key[${name}]!")
  }


  case $target {
    undef,'': {
      case $user {
        'root': { $real_target = '/root/.ssh/authorized_keys' }
        default: { $real_target = "/home/${user}/.ssh/authorized_keys" }
      }
    }
    default: {
      $real_target = $target
    }
  }
  ssh_authorized_key{$name:
    ensure => $ensure,
    type   => $type,
    key    => $key,
    user   => $user,
    target => $real_target,
  }

  case $options {
    'absent': { info("not setting any option for ssh_authorized_key: ${name}") }
    default: {
      Ssh_authorized_key[$name]{
        options => $options,
      }
    }
  }
}
