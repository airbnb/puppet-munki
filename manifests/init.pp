# Class: munki
#
# Installs and configures munki
# you must specify your own munki repo URL; please don't use http://munki and instead use a https URL.

class munki (
  String $munkitools_version,
  Boolean $apple_software_updates_only,
  String $client_cert_path,
  String $client_identifier,
  String $client_key_path,
  Integer $days_between_notifications,
  Boolean $install_apple_software_updates,
  Boolean $unattended_apple_updates,
  Integer $logging_level,
  Boolean $log_to_syslog,
  Boolean $msu_log_enabled,
  String $software_repo_ca_cert,
  String $software_repo_url,
  String $software_update_server_url,
  Boolean $suppress_user_notification,
  Boolean $use_client_cert,
  Boolean $show_removal_detail,
  Integer $days_before_broken,
  Array $additional_http_headers,
  String $payload_organization,
  String $package_source,
  Boolean $auto_run_after_install,
  Boolean $perform_auth_restarts,
  String $recovery_key_file,
  Integer $use_notification_center_days,
  Array $managed_installs,
  Array $managed_uninstalls,
  Boolean $show_optional_installs_for_higher_os_versions,
  String $local_only_manifest_name,
)
{
  class { '::munki::config': }
  -> class { '::munki::install': }
  -> class { '::munki::service': }
  -> Class['munki']

}
