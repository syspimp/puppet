class user::createusers {
  $users = hiera('user::userlist')
  $defaults = {
    'ensure'   => present,
  }
  create_resources(user, $users, $defaults)
}
