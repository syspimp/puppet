# vim:set noet:;
# vim:set sts=8 ts=8:;
# vim:set shiftwidth=8:;
class aliases ( $root_alias = hiera('root_alias') ) {
  file { '/etc/aliases':
    notify => Exec['newaliases'],
    alias  => 'aliases'
  }

  exec { 'newaliases':
    refreshonly => true,
  }

  Aliases::Alias_entry <| |>

  @aliases::alias_entry {
    'root':
      recipient => $root_alias;
    'abuse':;
    'adm':;
    'amanda':;
    'apache':;
    'bin':;
    'canna':;
    'daemon':;
    'dbus':;
    'desktop':;
    'dovecot':;
    'dumper':;
    'fax':;
    'ftp-adm':
      recipient => 'ftp';
    'ftpadm':
      recipient => 'ftp';
    'ftp-admin':
      recipient => 'ftp';
    'ftpadmin':
      recipient => 'ftp';
    'ftp':;
    'games':;
    'gdm':;
    'gopher':;
    'halt':;
    'hostmaster':;
    'ident':;
    'info':
      recipient => 'postmaster';
    'ingres':;
    'ldap':;
    'lp':;
    'mailer-daemon':
      recipient => 'postmaster';
    'mailnull':;
    'mail':;
    'manager':;
    'marketing':
      recipient => 'postmaster';
    'mysql':;
    'named':;
    'netdump':;
    'newsadmin':
      recipient => 'news';
    'newsadm':
      recipient => 'news';
    'news':;
    'nfsnobody':;
    'nobody':;
    'noc':;
    'nscd':;
    'ntp':;
    'nut':;
    'operator':;
    'pcap':;
    'postfix':;
    'postgres':;
    'postmaster':;
    'privoxy':;
    'puppet':
      recipient => 'root';
    'pvm':;
    'quagga':;
    'racks' :
      recipient => 'root';
    'radiusd':;
    'radvd':;
    'rpc':;
    'rpcuser':;
    'rpm':;
    'sales':
      recipient => 'postmaster';
    'security':;
    'shutdown':;
    'smmsp':;
    'squid':;
    'sshd':;
    'support':
      recipient => 'postmaster';
    'sync':;
    'system':;
    'toor':;
    'usenet':
      recipient => 'news';
    'uucp':;
    'vcsa':;
    'webalizer':;
    'webmaster':;
    'wnn':;
    'www':
      recipient => 'webmaster';
    'xfs':;
  }
}
