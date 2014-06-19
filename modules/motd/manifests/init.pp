# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:
class motd ( $root_alias = hiera('root_alias') )
{
      if $operatingsystem != "Windows" {
	file { "/etc/motd":
		content => template("motd/motd.erb")
	}
      }
}
