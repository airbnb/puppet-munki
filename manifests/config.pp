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


  $profile = {
              "PayloadContent" => [
        {
               "PayloadContent" => {
                "ManagedInstalls" => {
                    "Forced" => [
                        {
                            "mcx_preference_settings" => {
                                      "AdditionalHttpHeaders" => [
                                    'Authorization: Basic ***REMOVED***'
                                ],
                                   "AppleSoftwareUpdatesOnly" => $apple_software_updates_only,
                                      "ClientCertificatePath" => $client_cert_path,
                                              "ClientKeyPath" => $client_key_path,
                                   "DaysBetweenNotifications" => $days_between_notifications,
                                "InstallAppleSoftwareUpdates" => $install_apple_software_updates,
                                               "LoggingLevel" => $logging_level,
                                              "MSULogEnabled" => $msu_log_enabled,
                                  "SoftwareRepoCACertificate" => $software_repo_ca_cert,
                                    "SoftwareUpdateServerURL" => $software_update_server_url,
                                   "SuppressUserNotification" => $suppress_user_notification,
                                       "UseClientCertificate" => $use_client_cert
                            }
                        }
                    ]
                }
            },
               "PayloadEnabled" => true,
            "PayloadIdentifier" => "MCXToProfile.1dc15df4-d4c4-4b3a-b507-dd8f3b44f093.alacarte.customsettings.2beb4aeb-861b-4000-8c3a-d05117bf5ba7",
                  "PayloadType" => "com.apple.ManagedClient.preferences",
                  "PayloadUUID" => "2beb4aeb-861b-4000-8c3a-d05117bf5ba7",
               "PayloadVersion" => 1
        }
    ],
          "PayloadDescription" => "Included custom settings:\nManagedInstalls",
          "PayloadDisplayName" => "Settings for Munki",
           "PayloadIdentifier" => "ManagedInstalls",
         "PayloadOrganization" => "",
    "PayloadRemovalDisallowed" => true,
                "PayloadScope" => "System",
                 "PayloadType" => "Configuration",
                 "PayloadUUID" => "1dc15df4-d4c4-4b3a-b507-dd8f3b44f093",
              "PayloadVersion" => 1
  }

  mac_profiles_handler::manage { 'ManagedInstalls':
    ensure      => present,
    file_source => plist($profile),
    type        => 'template',
  }

}
