class user::setsudo ( $sudoers = '' )
{
  package { 'sudo':
		ensure => installed, # ensure sudo package installed
	}
  user::sudoenforce { $sudoers: }
}


define user::sudoenforce 
{
  $sudousers = hiera('user::userlist')
  $sudouser = $sudousers[$name]
  notify{"sudouser is name is $name, object is $sudouser":}
#	augeas { "sudo for ${sudouser['name']}":
#		context => "/files/etc/sudoers.d/${sudouser['primary_group']}", # target file is /etc/sudoers
#		changes => [
# 			"set spec[user = '%${sudouser['name']}']/user %${sudouser['name']}",
# 			"set spec[user = '%${sudouser['name']}']/host_group/host ALL",
# 			"set spec[user = '%${sudouser['name']}']/host_group/command ALL",
# 			"set spec[user = '%${sudouser['name']}']/host_group/command/runas_user ALL",
# 			"set spec[user = '%${sudouser['name']}']/host_group/command/tag ${sudouser['nopasswd']}",
#			]
#	}
}
