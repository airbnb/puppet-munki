# Configure munki via dynamic profile
class munki::config {
  $apple_software_updates_only    = $munki::apple_software_updates_only
  $client_cert_path               = $munki::client_cert_path
  $client_identifier              = $munki::client_identifier
  $client_key_path                = $munki::client_key_path
  $days_between_notifications     = $munki::days_between_notifications
  $install_apple_software_updates = $munki::install_apple_software_updates
  $logging_level                  = $munki::logging_level
  $msu_log_enabled                = $munki::msu_log_enabled
  $software_repo_ca_cert          = $munki::software_repo_ca_cert
  $software_repo_url              = $munki::software_repo_url
  $software_update_server_url     = $munki::software_update_server_url
  $suppress_user_notification     = $munki::suppress_user_notification
  $use_client_cert                = $munki::use_client_cert

  mac_profiles_handler::manage { 'ManagedInstalls':
    ensure      => present,
    file_source => template('munki/ManagedInstalls.mobileconfig.erb'),
    type        => 'template',
  }

}