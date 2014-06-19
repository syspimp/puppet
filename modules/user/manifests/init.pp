class user ($userlist = 'None' ){
  $allusers=user_list()
  include user::createusers
  include user::setsudo
  notify { "all usres are $allusers": }
  user::setkeys{ $allusers: }
  user::setpass{ $allusers: }
}
