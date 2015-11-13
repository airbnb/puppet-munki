# Class: munki
#
# Installs and configures munki

class munki (
  $munkitools_version             = '2.4.0.2561',
  $apple_software_updates_only    = false,
  $client_cert_path               = "${::ssldir}/certs/${::certname}.pem",
  $client_identifier              = undef,
  $client_key_path                = "${::ssldir}/private_keys/${::certname}.pem",
  $days_between_notifications     = 1,
  $install_apple_software_updates = true,
  $logging_level                  = 1,
  $msu_log_enabled                = true,
  $software_repo_ca_cert          = "${::ssldir}/certs/ca.pem",
  $software_repo_url              = 'https://***REMOVED***',
  $software_update_server_url     = undef,
  $suppress_user_notification     = false,
  $use_client_cert                = true,
){

  class { '::munki::config': } ->
  class { '::munki::install': } ->
  class { '::munki::service': } ->
  Class['munki']

}