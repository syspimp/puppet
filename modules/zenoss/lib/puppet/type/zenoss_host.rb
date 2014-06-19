#########################################################################
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Puppet Type: Zenoss_host
#
#
Puppet::Type.newtype(:zenoss_host) do
  @doc = "Manages hosts in Zenoss."

  ensurable

  newparam(:zenosssnmp) do
      # validation missing
      desc "The SNMP community string to use when modeling the device."
  end

  newparam(:state) do
      # validation missing
      desc "The production/qa/development environment to pass to zenoss, numeric."
  end

  newparam(:zenossuser) do
      # validation missing
      desc "The Zenoss DMD URI user, eg. 'http://user:pwd@localhost:8080/zport/dmd'."
  end

  newparam(:zenosspass) do
      # validation missing
      desc "The Zenoss DMD URI pass, eg. 'http://user:pwd@localhost:8080/zport/dmd'."
  end

  newparam(:zenosscollector) do
    # validation missing
    desc "The collector used by Zenoss to collect the data for this device."
  end

  newparam(:zenossuri) do
    # validation missing
    desc "The Zenoss DMD URIi, eg. 'http://user:pwd@localhost:8080/zport/dmd'."
  end

  newparam(:serialnumber) do
    # validation missing
    desc "The serial number of the host that should be added."
  end

  newparam(:grouppath) do
    # validation missing
    desc "The Zenoss group path."
  end

  newparam(:systempath) do
    # validation missing
    desc "The Zenoss system path."
  end

  newparam(:name) do
    desc "The name of the host."
    isnamevar
    # validation missing
  end

  newparam(:ip) do
    # validation missing
    desc "The IP address of the host."
  end

  newparam(:zenosstype) do
    desc "The host type (kernel fact)."
    # validation missing

    # munge values, depending on the kernel of the system
    # if zenosstype depends on more than just the kernel
    #  this should be solved with a custom fact.
    munge do |value|
      case value
      when "Linux"
        "/Server/Linux"
      when "xen0"
        "/Server/Virtual Machine Host/Xen"
      when "AIX"
        "/Server/AIX"
      when "SunOS"
        "/Server/Solaris"
      when "windows"
        "/Server/Windows"
      else
        "/Server"
      end
    end
  end

end
