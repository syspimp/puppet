# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:

module Puppet::Parser::Functions
        require 'ipaddr'
        newfunction(:datacenter, :type => :rvalue) do |args|
        addr = args[0]
        $KCODE = 'utf-8'
        output = {}
        mask   = 0
        dcs = {
          "openstack"                    => [ "10.55.4.0/24" ],
          "physical"                      => [ "10.55.2.0/24" ],
        }

        dcs.keys.each { |dc|
          dcs[dc].each { |net|
            netaddr = IPAddr.new(net)
            ipaddr  = IPAddr.new(addr)
            if netaddr.include?(ipaddr)
              output[dc] = netaddr.instance_variable_get("@mask_addr")
            end
          }
        }

        if output.keys == []
          return "openstack"
        end

        answer = (output.keys.select{|i| output[i] > mask && mask = output[i] }).select{|i| output[i] == mask}[0]
        return answer
        end
end
