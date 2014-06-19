define nodeless ($module = $title) {
  if $module != "nodeless" {
    if fact_enabled($module) {
#      notify { "$module is enabled on node $fqdn": }
      include $module
    }
  }
}
