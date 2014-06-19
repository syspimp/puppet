module Puppet::Parser::Functions
  newfunction(:user_list, :type => :rvalue) do |args|
    list = Array.new
    users=lookupvar("user::userlist")
    list=users.keys
    list
  end # puppet function user_list
end # module Puppet::Parser::Functions

