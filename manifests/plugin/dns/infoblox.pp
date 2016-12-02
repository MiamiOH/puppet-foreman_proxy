# = Foreman Proxy Infoblox DNS plugin
#
# This class installs the Infoblox DNS plugin for Foreman proxy
#
# === Parameters:
#
# $dns_server:: The address of the Infoblox server
#
# $username::   The username of the Infoblox user
#
# $password::   The password of the Infoblox user
#
class foreman_proxy::plugin::dns::infoblox (
  $dns_server = $::foreman_proxy::plugin::dns::infoblox::params::dns_server,
  $username   = $::foreman_proxy::plugin::dns::infoblox::params::username,
  $password   = $::foreman_proxy::plugin::dns::infoblox::params::password,
  $proxy_uri  = undef,
) inherits foreman_proxy::plugin::dns::infoblox::params {
  validate_string($dns_server, $username, $password)

  $install_options = $proxy_uri ? {
    undef   => undef,
    default => [{'--http-proxy' => $proxy_uri}],
  }

  ensure_packages(['smart_proxy_dns_infoblox', 'infoblox'], {
    ensure          => $foreman_proxy::plugin_version,
    provider        => gem,
    install_options => $install_options,
    before          => File['/usr/share/foreman-proxy/bundler.d/dns_infoblox.rb'],
  })
  file { '/usr/share/foreman-proxy/bundler.d/dns_infoblox.rb':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "gem 'smart_proxy_dns_infoblox'",
  } ->
  foreman_proxy::settings_file { 'dns_infoblox':
    module        => false,
    template_path => 'foreman_proxy/plugin/dns_infoblox.yml.erb',
  }
}
