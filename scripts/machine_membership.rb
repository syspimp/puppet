Facter.add('check_machine_membership') do
  setcode do
    hostname = Facter.value(:hostname)
    Facter::Util::Resolution.exec("check_membership.py -c -t #{hostname}")
  end
end

