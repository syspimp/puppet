#########################################################################
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


# Puppet Provider Zenoss
#
#
require 'uri'
require "xmlrpc/client"
Puppet::Type.type(:zenoss_host).provide(:zenoss) do
  desc "Provider for ZenOSS.
        http://www.zenoss.com/community/docs/howtos/send-events/
        http://www.zenoss.com/community/docs/howtos/add-device/"

  ##
  #
  # this method checks if a given device exists in the given device path
  # it is called to check if a device was already added
  #
  def exists?
    debug("<== calling existsDevice...")
    uribase = resource[:zenossuri]
    uriext = "/Devices#{resource[:zenosstype]}/devices/#{resource[:name]}"
    uri = "#{uribase}#{uriext}"
    debug("The URI: #{uri}")
    s = XMLRPC::Client.new2("#{URI.escape(uri)}")
    begin
      debug("get Id: #{s.call('getId')}")
      return true
    rescue XMLRPC::FaultException => fe # device does not exist
      return false
    end
  rescue XMLRPC::FaultException => e
    err(e.faultCode)
    err(e.faultString)
  end

  ##

  #
  # The device is added with its name.
  #
  def create
    info("==> Adding device '#{resource[:alias]}' by ip #{resource[:ip]} to Zenoss ...")
    router_action = "DeviceRouter"
    router_method = "addDevice"
    router_endpoint = "/device_router"
    uribase = resource[:zenossuri]
    zenosscollector = resource[:zenosscollector]
    grouppath = resource[:grouppath]
    systempath = resource[:systempath]
    serialnumber = resource[:serialnumber]
    zenosssnmp = resource[:zenosssnmp]
    zenosstype = resource[:zenosstype]
    zenossuser = resource[:zenossuser]
    zenosspass = resource[:zenosspass]
    ip = resource[:ip]
    name = resource[:name]
    state = resource[:state]
    uri = "#{uribase}#{router_endpoint}"
    login = "/zport/acl_users/cookieAuthHelper/login?__ac_name=#{zenossuser}&__ac_password=#{zenosspass}&submitted=true&came_from=#{uribase}"
    data = "{\"deviceName\":\"#{ip}\",\"deviceClass\":\"#{zenosstype}\",\"collector\":\"#{zenosscollector}\",\"model\":true,\"title\":\"\",\"productionState\":\"#{state}\",\"priority\":\"3\",\"snmpCommunity\":\"#{zenosssnmp}\",\"snmpPort\":161,\"tag\":\"\",\"rackSlot\":\"\",\"serialNumber\":\"\",\"hwManufacturer\":\"\",\"hwProductName\":\"\",\"osManufacturer\":\"\",\"osProductName\":\"\",\"comments\":\"\"}"
    action = "{\"action\":\"#{router_action}\",\"method\":\"#{router_method}\",\"data\":[#{data}], \"tid\":1}"
    info("The URI: #{uri}")
    url = URI(uribase)
    http = Net::HTTP.new(url.host, url.port)
    ###
    #loginurl = URI("#{uribase}#{login}")
    createurl = URI("#{uribase}#{router_endpoint}")
    info("full is '#{uribase}#{router_endpoint}' createurl is #{createurl.host} and #{createurl.port}")
    #request = Net::HTTP::Get.new(loginurl.path)
    #response = http.request(request)
    #debug("login response: #{response.body}")
    req = Net::HTTP::Post.new(createurl.path)
    req['Content-Type'] = 'application/json'
    req.body = action
    req.basic_auth zenossuser, zenosspass
    debug('mark')
    debug("data is #{req.body}")
    resp = http.request(req)
    #info("resp.body is #{resp.body}")
            if resp.code == '200'
                result = "'200' => successfully added device."
                info("<== result: #{result}")
                # if the device was successuffly added, rename it.
                renameDevice(resource[:ip], resource[:zenosstype], resource[:name])
            #elsif out == 1
            elsif resp.code == 1
                result = "'1' => device could not be added, may be it already exists (actually this should be error code '2' ...). May be there is something wrong with the Zenoss server."
                err("<== result: #{result}")
            else
                #result = out.to_s
                result = resp.body
                err("<== result: Unknown return code: '#{resp.code}' body: '#{result}'")
            end

  rescue XMLRPC::FaultException => e
    err("Error occurred while adding the device.")
    err("Error code:")
    err(e.faultCode)
    err("Error string:")
    err(e.faultString)
    return false
  end

  def destroy
    info("==> Delete the device #{resource[:name]}")
    uribase = resource[:zenossuri]
    uriext = "/Devices#{resource[:zenosstype]}/devices/#{resource[:name]}"
    uri = "#{uribase}#{uriext}"
    debug("The URI: <uribase>#{uriext}")
    s = XMLRPC::Client.new2("#{URI.escape(uri)}")
    out = s.call("deleteDevice",  "#{resource[:name]}")
    debug("|| result: #{out}")
    info("<== device successfully deleted.")
    return true
  rescue RuntimeError => re
    if re.to_s =~ /HTTP-Error: 302 Moved Temporarily/
      debug("ignore 'HTTP-Error: 302 Moved Temporarily'.")
      info("<== device successfully deleted.")
      return true
    else
      err("#{failmsg}")
      err(re)
      return false
    end
  rescue Exception => e
    err("Error code:")
    err(e.faultCode)
    err("Error string:")
    err(e.faultString)
    return false
  end

    def renameDevice(_devName, _devPath, _newDevName)
        begin
            failmsg = "Could not rename the device, #{_newDevName} may already exist!"
            info("==> Rename the device #{_devName} to #{_newDevName} ...")
            uribase = resource[:zenossuri]
            uriext = "/Devices#{_devPath}/devices/#{_devName}"
            uri = "#{uribase}#{uriext}"
            #debug("The URI: <uribase>#{uriext}")
            debug("The URI: <uri>#{uri}")
            s = XMLRPC::Client.new2("#{uri}")
            out = s.call("renameDevice", "#{_newDevName}")
            debug("|| result: #{out}")
            info("<== device successfully renamed.")
            return true
        rescue RuntimeError => re
            if re.inspect =~ /HTTP-Error: 302 Moved Temporarily/
                debug("ignore 'HTTP-Error: 302 Moved Temporarily'.")
                info("<== device successfully renamed.")
                return true
            else
                err("#{failmsg}")
                err(re)
                return false
            end
        rescue Exception => e
            info("#{failmsg}")
            #err("Error code:")
            #err(e.faultCode)
            #err("Error string:")
            #err(e.faultString)
            return true
        end
    end
end
