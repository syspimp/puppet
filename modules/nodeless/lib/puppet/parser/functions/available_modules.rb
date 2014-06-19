require 'puppet'

module Puppet::Parser::Functions
  newfunction(:available_modules, :type => :rvalue) do |args|
    modules = Array.new
    Puppet::Node::Environment.new(lookupvar("::environment")).modules.each { |x| modules << x.name }
    modules
  end # puppet function fact_enabled
end # module Puppet::Parser::Functions
