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
  String $munkitools_source,
  String $munkitools_core_source,
  String $munkitools_admin_source,
  String $munkitools_app_usage_source,
  String $munkitools_app_source,
  String $munkitools_launchd_source,
  String $munkitools_receipt,
  String $munkitools_core_receipt,
  String $munkitools_admin_receipt,
  String $munkitools_app_usage_receipt,
  String $munkitools_app_receipt,
  String $munkitools_launchd_receipt,
  String $munkitools_checksum,
  String $munkitools_core_checksum,
  String $munkitools_admin_checksum,
  String $munkitools_app_usage_checksum,
  String $munkitools_app_checksum,
  String $munkitools_launchd_checksum,
  String $munkitools_version,
  String $munkitools_core_version,
  String $munkitools_admin_version,
  String $munkitools_app_usage_version,
  String $munkitools_app_version,
  String $munkitools_launchd_version,
  Boolean $auto_run_after_install,
  Boolean $perform_auth_restarts,
  String $recovery_key_file,
  Integer $use_notification_center_days,
  Array $managed_installs,
  Array $managed_uninstalls,
  Boolean $show_optional_installs_for_higher_os_versions,
  String $local_only_manifest_name,
  Boolean $use_aio,
  String $http_user,
  String $http_password,
)
{
  class { '::munki::config': }
  -> class { '::munki::install': }
  -> class { '::munki::service': }
  -> Class['munki']

}
