define user::setkeys()
{
  $users = hiera('user::userlist')
  $user = $users[$name]
  if has_key($user,'sshkey')
  {
#	  ssh_authorized_key {
#			"$user['name']":
#			ensure => present,
#			type => "$user['sshtype']",
#			key => "$user['sshkey']",
#			user => "$user['name']",
#    }
  }
}
