# This ensures aliases made to real email addresses
define aliases::alias_entry($recipient=root, $ensure=present) {
  mailalias {
    $name:
      ensure    => $ensure;
      recipient => $recipient,
      notify    => Exec['newaliases'],
  }
}
