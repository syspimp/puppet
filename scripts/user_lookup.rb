# if you have an array of users in hiera, this will return their name
# users:
#   my_usrs_name:
#     name: my_usrs_name
#     groups:
#       - my_usrs_name
# ...

module Puppet::Parser::Functions
  newfunction(:user_lookup, :type => :rvalue) do |args|
    list = Array.new
    users=hiera_object.lookup('users')
    users.each do |user|
        list << user['name']
    end
    list
  end # puppet function user_lookup
end # module Puppet::Parser::Functions

