# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:
define user::setpass($file='/etc/shadow') {
  $users=hiera('user::userlist')
  $user=$users[$name]
  user::ensure_key_value{ "set_pass_$name":
    file      => $file,
    key       => $name,
    value     => "${user['passwd']}:13572:0:99999:7:::",
    delimiter => ':'
  }
}
