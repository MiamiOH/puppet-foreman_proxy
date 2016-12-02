# = Foreman Proxy Infoblox DHCP
#
# This class installs the Infoblox DNS plugin for Foreman proxy
#
# === Parameters:
#
# $username::    The username of the Infoblox user
#
# $password::    The password of the Infoblox user
#
# $record_type:: Record type to manage, can be "host" or "fixedaddress"
#
# $use_ranges::  Use  pre-definded ranges in networks to find available IP's
#                type:boolean
#
class foreman_proxy::plugin::dhcp::infoblox (
  $username    = $::foreman_proxy::plugin::dhcp::infoblox::params::username,
  $password    = $::foreman_proxy::plugin::dhcp::infoblox::params::password,
  $record_type = $::foreman_proxy::plugin::dhcp::infoblox::params::record_type,
  $use_ranges  = $::foreman_proxy::plugin::dhcp::infoblox::params::use_ranges,
  $proxy_uri   = undef,
) inherits foreman_proxy::plugin::dhcp::infoblox::params {
  validate_string($username, $password)
  validate_re($record_type, '^host|fixedaddress$', 'Invalid record type: choose host or fixedaddress')
  validate_bool($use_ranges)

  $install_options = $proxy_uri ? {
    undef   => undef,
    default => [{'--http-proxy' => $proxy_uri}],
  }

  ensure_packages(['smart_proxy_dhcp_infoblox', 'infoblox'], {
    ensure          => $foreman_proxy::plugin_version,
    provider        => gem,
    install_options => $install_options,
    before          => File['/usr/share/foreman-proxy/bundler.d/dhcp_infoblox.rb'],
  })
  file { '/usr/share/foreman-proxy/bundler.d/dhcp_infoblox.rb':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "gem 'smart_proxy_dhcp_infoblox'\ngem 'infoblox'",
  } ->
  foreman_proxy::settings_file { 'dhcp_infoblox':
    module        => false,
    template_path => 'foreman_proxy/plugin/dhcp_infoblox.yml.erb',
  }
}
