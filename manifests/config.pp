# Configure munki via dynamic profile
class munki::config {
  $aggressive_update_notification_days           = $munki::aggressive_update_notification_days
  $apple_software_updates_only                   = $munki::apple_software_updates_only
  $client_cert_path                              = $munki::client_cert_path
  $client_identifier                             = $munki::client_identifier
  $client_key_path                               = $munki::client_key_path
  $days_between_notifications                    = $munki::days_between_notifications
  $install_apple_software_updates                = $munki::install_apple_software_updates
  $unattended_apple_updates                      = $munki::unattended_apple_updates
  $logging_level                                 = $munki::logging_level
  $log_to_syslog                                 = $munki::log_to_syslog
  $msu_log_enabled                               = $munki::msu_log_enabled
  $software_repo_ca_cert                         = $munki::software_repo_ca_cert
  $software_repo_url                             = $munki::software_repo_url
  $software_update_server_url                    = $munki::software_update_server_url
  $suppress_user_notification                    = $munki::suppress_user_notification
  $suppress_loginwindow_install                  = $munki::suppress_loginwindow_install
  $use_client_cert                               = $munki::use_client_cert
  $additional_http_headers                       = $munki::additional_http_headers
  $payload_organization                          = $munki::payload_organization
  $show_removal_detail                           = $munki::show_removal_detail
  $recovery_key_file                             = $munki::recovery_key_file
  $perform_auth_restarts                         = $munki::perform_auth_restarts
  $use_notification_center_days                  = $munki::use_notification_center_days
  $show_optional_installs_for_higher_os_versions = $munki::show_optional_installs_for_higher_os_versions
  $local_only_manifest_name                      = $munki::local_only_manifest_name
  $manage_profile                                = $munki::manage_profile
  $msc_offer_to_quit_blocking_apps               = $munki::msc_offer_to_quit_blocking_apps
  $msc_offer_to_force_quit_blocking_apps         = $munki::msc_offer_to_force_quit_blocking_apps
  $msc_offer_to_update_others                    = $munki::msc_offer_to_update_others
  $custom_sidebar_items                          = $munki::custom_sidebar_items
  $download_retries                              = $munki::download_retries
  $download_retry_sleep_seconds                  = $munki::download_retry_sleep_seconds

  $mcx_settings = {
    'AdditionalHttpHeaders' => $additional_http_headers,
    'AggressiveUpdateNotificationDays' => $aggressive_update_notification_days,
    'AppleSoftwareUpdatesOnly' => $apple_software_updates_only,
    'ClientIdentifier' => $client_identifier,
    'DaysBetweenNotifications' => $days_between_notifications,
    'DownloadRetries' => $download_retries,
    'DownloadRetrySleepSeconds' => $download_retry_sleep_seconds,
    'InstallAppleSoftwareUpdates' => $install_apple_software_updates,
    'UnattendedAppleUpdates' => $unattended_apple_updates,
    'LoggingLevel' => $logging_level,
    'LogToSyslog' => $log_to_syslog,
    'MSCOfferToQuitBlockingApps' => $msc_offer_to_quit_blocking_apps,
    'MSCOfferToForceQuitBlockingApps' => $msc_offer_to_force_quit_blocking_apps,
    'MSCOfferToUpdateOthers' => $msc_offer_to_update_others,
    'MSULogEnabled' => $msu_log_enabled,
    'SoftwareRepoURL' => $software_repo_url,
    'SuppressLoginwindowInstall' => $suppress_loginwindow_install,
    'SuppressUserNotification' => $suppress_user_notification,
    'UseClientCertificate' => $use_client_cert,
    'ShowRemovalDetail' => $show_removal_detail,
    'PerformAuthRestarts' => $perform_auth_restarts,
    'RecoveryKeyFile' => $recovery_key_file,
    'UseNotificationCenterDays' => $use_notification_center_days,
    'ShowOptionalInstallsForHigherOSVersions' => $show_optional_installs_for_higher_os_versions
  }
  $managed_installs = lookup('munki::managed_installs', Array, 'unique', [])
  $managed_uninstalls = lookup('munki::managed_uninstalls', Array, 'unique', [])

  if $custom_sidebar_items != [] {
    $settings_with_sidebar = merge($mcx_settings, {'CustomSidebarItems' => $custom_sidebar_items})
  } else {
    $settings_with_sidebar = $mcx_settings
  }

  if $use_client_cert == true {
    $cert_settings = {'ClientCertificatePath' => $client_cert_path, 'ClientKeyPath' => $client_key_path, 'SoftwareRepoCACertificate' => $software_repo_ca_cert}
    $settings_with_cert = merge($settings_with_sidebar, $cert_settings)
  } else {
    $settings_with_cert = $settings_with_sidebar
  }

  if $software_update_server_url != '' {
    $sus_settings = {'software_update_server_url' => $software_update_server_url}
    $settings_with_sus_url = merge($settings_with_cert, $sus_settings)
  } else {
    $settings_with_sus_url = $settings_with_cert
  }

  if $managed_installs != [] or $managed_uninstalls != [] {
    # merge existing settings with 'LocalOnlyManifest' pref string
    $local_only_manifest = {'LocalOnlyManifest' => $local_only_manifest_name}
    $settings_to_write = merge($settings_with_sus_url, $local_only_manifest)
  } else {
    # just copy the existing to $settings_to_write
    $settings_to_write = $settings_with_sus_url
  }

  class {'munki::local_only_manifest' :
    managed_installs   => $managed_installs,
    managed_uninstalls => $managed_uninstalls,
    manifest_name      => $local_only_manifest_name
  }

  $profile = {
    'PayloadContent' => [
      {
        'PayloadContent' => {
          'ManagedInstalls' => {
            'Forced' => [
              {
                'mcx_preference_settings' => $settings_to_write
              }
            ]
          }
        },
        'PayloadEnabled' => true,
        'PayloadIdentifier' => 'MCXToProfile.1dc15df4-d4c4-4b3a-b507-dd8f3b44f093.alacarte.customsettings.2beb4aeb-861b-4000-8c3a-d05117bf5ba7', # lint:ignore:140chars
        'PayloadType' => 'com.apple.ManagedClient.preferences',
        'PayloadUUID' => '2beb4aeb-861b-4000-8c3a-d05117bf5ba7',
        'PayloadVersion' => 1
      }
    ],
    'PayloadDescription' => "Included custom settings:\nManagedInstalls",
    'PayloadDisplayName' => 'Settings for Munki',
    'PayloadIdentifier' => 'ManagedInstalls',
    'PayloadOrganization' => $payload_organization,
    'PayloadRemovalDisallowed' => true,
    'PayloadScope' => 'System',
    'PayloadType' => 'Configuration',
    'PayloadUUID' => '1dc15df4-d4c4-4b3a-b507-dd8f3b44f093',
    'PayloadVersion' => 1
  }

  if $manage_profile {
    mac_profiles_handler::manage { 'ManagedInstalls':
      ensure      => present,
      file_source => plist($profile),
      type        => 'template',
    }
  }

}
