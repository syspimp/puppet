require 'puppet'
require 'facter'

module Puppet::Parser::Functions
  newfunction(:fact_enabled, :type => :rvalue) do |args|
    factname = "nodeless_" + args[0]
    function_notice(["checking if fact enabled nodeless_#{args[0]}"])
    result = lookupvar(factname)
    lookupvar(factname) != nil
  end # puppet function fact_enabled
end # module Puppet::Parser::Functions
