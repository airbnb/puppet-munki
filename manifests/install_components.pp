class munki::install_components {
  $munkitools_source = $munki::munkitools_source
  $munkitools_version = $munki::munkitools_version
  $days_before_broken = $munki::days_before_broken

  if $munkitools_source != '' {
    $actual_munkitools_source = $munkitools_source
  } else {
    $actual_munkitools_source = "puppet:///modules/bigfiles/munki/munkitools-${munkitools_version}.pkg"
  }

  $munkitools_core_source = $munki::munkitools_core_source
  $munkitools_core_version = $munki::munkitools_core_version

  if $munkitools_core_source != '' {
    $actual_munkitools_core_source = $munkitools_core_source
  } else {
    $actual_munkitools_core_source = "puppet:///modules/bigfiles/munki/munkitools_core-${munkitools_core_version}.pkg"
  }

  $munkitools_python_source = $munki::munkitools_python_source
  $munkitools_python_version = $munki::munkitools_python_version

  if $munkitools_python_source != '' {
    $actual_munkitools_python_source = $munkitools_python_source
  } else {
    $actual_munkitools_python_source = "puppet:///modules/bigfiles/munki/munkitools_python-${munkitools_python_version}.pkg"
  }


  $munkitools_admin_source = $munki::munkitools_admin_source
  $munkitools_admin_version = $munki::munkitools_admin_version

  if $munkitools_admin_source != '' {
    $actual_munkitools_admin_source = $munkitools_admin_source
  } else {
    $actual_munkitools_admin_source = "puppet:///modules/bigfiles/munki/munkitools_admin-${munkitools_admin_version}.pkg"
  }

  $munkitools_app_usage_source = $munki::munkitools_app_usage_source
  $munkitools_app_usage_version = $munki::munkitools_app_usage_version

  if $munkitools_app_usage_source != '' {
    $actual_munkitools_app_usage_source = $munkitools_app_usage_source
  } else {
    $actual_munkitools_app_usage_source = "puppet:///modules/bigfiles/munki/munkitools_app_usage-${munkitools_app_usage_version}.pkg"
  }

  $munkitools_launchd_source = $munki::munkitools_launchd_source
  $munkitools_launchd_version = $munki::munkitools_launchd_version

  if $munkitools_launchd_source != '' {
    $actual_munkitools_launchd_source = $munkitools_launchd_source
  } else {
    $actual_munkitools_launchd_source = "puppet:///modules/bigfiles/munki/munkitools_launchd-${munkitools_launchd_version}.pkg"
  }


  # $today = strftime('%s')
  $now = time()
  # $today - (86400 seconds in a day * $days_before_broken)
  $broken_days_ago = $now - (86400 * $days_before_broken)
  if $facts['munki_last_run_unix'] > 0 and
  $facts['munki_last_run_unix'] < $broken_days_ago and
  $facts['munki_running'] == false {
    $force_install = true
  }
  elsif ($facts['munki_dir_exists'] == false or
    $facts['munki_version'] == 0 or
  versioncmp($facts['munki_version'], $munkitools_core_version) < 0) and
  $facts['munki_running'] == false {
    $force_install = true
    exec {'forget_munki_pkgs':
      command => '/bin/rm -rf /usr/local/munki/munkilib
      /usr/sbin/pkgutil --forget com.googlecode.munki.admin
      /usr/sbin/pkgutil --forget com.googlecode.munki.app
      /usr/sbin/pkgutil --forget com.googlecode.munki.core
      /usr/sbin/pkgutil --forget com.googlecode.munki.launchd
      /usr/sbin/pkgutil --forget com.googlecode.munki.app_usage
      exit 0',
      before  => [
        Apple_package['munkitools'],
        Apple_package['munkitools_core'],
        Apple_package['munkitools_admin'],
        Apple_package['munkitools_app_usage'],
        Apple_package['munkitools_launchd']
      ]
    }
  } else {
    $force_install = false
  }

  apple_package { 'munkitools':
    source        => $actual_munkitools_source,
    version       => $munkitools_version,
    receipt       => $munki::munkitools_receipt,
    installs      => ['/Applications/Managed Software Center.app/Contents/MacOS/Managed Software Center'], # lint:ignore:140chars
    force_install => $force_install,
    http_checksum => $munki::munkitools_checksum,
    http_username => $munki::http_user,
    http_password => $munki::http_password
  }

  if versioncmp($munkitools_python_version, '3.8.0') > 0 {
    $python_installs = ['/usr/local/munki/Python.framework', '/usr/local/munki/munki-python']
  } else {
    $python_installs = ['/usr/local/munki/Python.framework', '/usr/local/munki/python']
  }
  if $munki::munki_python {
    apple_package { 'munkitools_python':
      source        => $actual_munkitools_python_source,
      version       => $munkitools_python_version,
      receipt       => $munki::munkitools_python_receipt,
      installs      => $python_installs,
      force_install => $force_install,
      http_checksum => $munki::munkitools_python_checksum,
      http_username => $munki::http_user,
      http_password => $munki::http_password
    }
  }

  apple_package { 'munkitools_core':
    source        => $actual_munkitools_core_source,
    version       => $munkitools_core_version,
    receipt       => $munki::munkitools_core_receipt,
    installs      => [
      '/usr/local/munki/managedsoftwareupdate',
      '/usr/local/munki/authrestartd',
      '/usr/local/munki/launchapp',
      '/usr/local/munki/ptyexec',
      '/usr/local/munki/removepackages',
      '/usr/local/munki/supervisor',
    ],
    force_install => $force_install,
    http_checksum => $munki::munkitools_core_checksum,
    http_username => $munki::http_user,
    http_password => $munki::http_password
  }

  apple_package { 'munkitools_admin':
    source        => $actual_munkitools_admin_source,
    version       => $munkitools_admin_version,
    receipt       => $munki::munkitools_admin_receipt,
    installs      => [
      '/usr/local/munki/iconimporter',
      '/usr/local/munki/makecatalogs',
      '/usr/local/munki/makepkginfo',
      '/usr/local/munki/manifestutil',
      '/usr/local/munki/munkiimport',
    ],
    force_install => $force_install,
    http_checksum => $munki::munkitools_admin_checksum,
    http_username => $munki::http_user,
    http_password => $munki::http_password
  }

  apple_package { 'munkitools_app_usage':
    source        => $actual_munkitools_app_usage_source,
    version       => $munkitools_app_usage_version,
    receipt       => $munki::munkitools_app_usage_receipt,
    installs      => [
      '/Library/LaunchDaemons/com.googlecode.munki.appusaged.plist',
      '/Library/LaunchAgents/com.googlecode.munki.app_usage_monitor.plist',
      '/usr/local/munki/appusaged',
      '/usr/local/munki/app_usage_monitor'
    ],
    force_install => $force_install,
    http_checksum => $munki::munkitools_app_usage_checksum,
    http_username => $munki::http_user,
    http_password => $munki::http_password
  }

  apple_package { 'munkitools_launchd':
    source        => $actual_munkitools_launchd_source,
    version       => $munkitools_launchd_version,
    receipt       => $munki::munkitools_launchd_receipt,
    installs      => [
      '/Library/LaunchDaemons/com.googlecode.munki.managedsoftwareupdate-check.plist',
      '/Library/LaunchDaemons/com.googlecode.munki.managedsoftwareupdate-install.plist',
      '/Library/LaunchDaemons/com.googlecode.munki.managedsoftwareupdate-manualcheck.plist',
      '/Library/LaunchDaemons/com.googlecode.munki.logouthelper.plist',
    ],
    force_install => $force_install,
    notify        => [
      Exec['munki_reload_launchagents'],
      Service['com.googlecode.munki.managedsoftwareupdate-check'],
      Service['com.googlecode.munki.managedsoftwareupdate-install'],
      Service['com.googlecode.munki.managedsoftwareupdate-manualcheck']
    ],
    http_checksum => $munki::munkitools_launchd_checksum,
    http_username => $munki::http_user,
    http_password => $munki::http_password
  }


}
