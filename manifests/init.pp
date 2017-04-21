# Class: munki
#
# Installs and configures munki
# you must specify your own munki repo URL; please don't use http://munki and instead use a https URL.

class munki (
  String $munkitools_version              = '2.8.0.2810',
  Boolean $apple_software_updates_only    = false,
  String $client_cert_path                = "${facts['ssldir']}/certs/${facts['certname']}.pem",
  String $client_identifier               = '',
  String $client_key_path                 = "${facts['ssldir']}/private_keys/${facts['certname']}.pem",
  Integer $days_between_notifications     = 1,
  Boolean $install_apple_software_updates = true,
  Boolean $unattended_apple_updates       = false,
  Integer $logging_level                  = 1,
  Boolean $log_to_syslog                  = false,
  Boolean $msu_log_enabled                = false,
  String $software_repo_ca_cert           = "${facts['ssldir']}/certs/ca.pem",
  String $software_repo_url               = '',
  Any $software_update_server_url         = undef,
  Boolean $suppress_user_notification     = false,
  Boolean $use_client_cert                = false,
  Boolean $show_removal_detail            = false,
  Integer $days_before_broken             = 60,
  Array $additional_http_headers          = [],
  String $payload_organization            = '',
  String $package_source                  = "puppet:///modules/bigfiles/munki/munkitools-${munkitools_version}.pkg",
  Boolean $auto_run_after_install         = true,
  Boolean $perform_auth_restarts          = false,
  String $recovery_key_file               = '',
  Integer $use_notification_center_days   = 3,
){

  class { '::munki::config': } ->
  class { '::munki::install': } ->
  class { '::munki::service': } ->
  class { '::munki::auto_run': } ->
  Class['munki']

}
