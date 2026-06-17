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

  # Munki 7 (the Swift rewrite) changed both the set of component packages and
  # the on-disk layout used to detect them. Gate on the core package version so
  # a single repo can roll out both: < 7 uses the Munki 6 packages/paths,
  # >= 7 uses the Munki 7 packages/paths. An unset core version (the default)
  # resolves to false, preserving the Munki 6 layout.
  $is_munki7 = versioncmp($munkitools_core_version, '7') >= 0

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

  # Munki 7 replaced the bundled Python interpreter (munkitools_python) with two new components:
  # munkitools_pythonlibs (the munkilib Python library) and munkitools_libs (Swift runtime dylibs, only needed on macOS < 12)
  $munkitools_pythonlibs_source = $munki::munkitools_pythonlibs_source
  $munkitools_pythonlibs_version = $munki::munkitools_pythonlibs_version

  if $munkitools_pythonlibs_source != '' {
    $actual_munkitools_pythonlibs_source = $munkitools_pythonlibs_source
  } else {
    $actual_munkitools_pythonlibs_source = "puppet:///modules/bigfiles/munki/munkitools_pythonlibs-${munkitools_pythonlibs_version}.pkg"
  }

  $munkitools_libs_source = $munki::munkitools_libs_source
  $munkitools_libs_version = $munki::munkitools_libs_version

  if $munkitools_libs_source != '' {
    $actual_munkitools_libs_source = $munkitools_libs_source
  } else {
    $actual_munkitools_libs_source = "puppet:///modules/bigfiles/munki/munkitools_libs-${munkitools_libs_version}.pkg"
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

  # Python handling differs by Munki version. Munki 6 and earlier bundle a Python
  # interpreter in munkitools_python. Munki 7 splits this into munkitools_pythonlibs
  # (the munkilib Python library) and munkitools_libs (Swift runtime dylibs). Each
  # package keeps its own toggle so a single repo can roll out both Munki 6 and 7.
  if $is_munki7 {
    # Munki 7: the munkilib Python library, used by the admin CLI tools.
    # Replaces the on-disk half of the old munkitools_python package.
    if $munki::munki_pythonlibs {
      apple_package { 'munkitools_pythonlibs':
        source        => $actual_munkitools_pythonlibs_source,
        version       => $munkitools_pythonlibs_version,
        receipt       => $munki::munkitools_pythonlibs_receipt,
        installs      => ['/usr/local/munki/munkilib'],
        force_install => $force_install,
        http_checksum => $munki::munkitools_pythonlibs_checksum,
        http_username => $munki::http_user,
        http_password => $munki::http_password
      }
    }

    # Munki 7: Swift runtime dylibs. Only needed on macOS < 12; newer macOS ships
    # the Swift concurrency runtime in the OS.
    if $munki::munki_libs and versioncmp($facts['os']['macosx']['version']['major'], '12') < 0 {
      apple_package { 'munkitools_libs':
        source        => $actual_munkitools_libs_source,
        version       => $munkitools_libs_version,
        receipt       => $munki::munkitools_libs_receipt,
        installs      => ['/usr/local/munki/lib/libswift_Concurrency.dylib'],
        force_install => $force_install,
        http_checksum => $munki::munkitools_libs_checksum,
        http_username => $munki::http_user,
        http_password => $munki::http_password
      }
    }
  } elsif $munki::munki_python {
    # Munki 6 and earlier: the bundled Python interpreter package.
    if versioncmp($munkitools_python_version, '3.8.0') > 0 {
      $python_installs = ['/usr/local/munki/Python.framework', '/usr/local/munki/munki-python']
    } else {
      $python_installs = ['/usr/local/munki/Python.framework', '/usr/local/munki/python']
    }
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

  # Munki 7 (Swift rewrite) moved most helper binaries under libexec/ and dropped
  # ptyexec and supervisor; Munki 6 keeps them at the top level of /usr/local/munki.
  if $is_munki7 {
    $munkitools_core_installs = [
      '/usr/local/munki/managedsoftwareupdate',
      '/usr/local/munki/removepackages',
      '/usr/local/munki/libexec/authrestartd',
      '/usr/local/munki/libexec/launchapp',
      '/usr/local/munki/libexec/logouthelper',
      '/usr/local/munki/libexec/precache_agent',
    ]
  } else {
    $munkitools_core_installs = [
      '/usr/local/munki/managedsoftwareupdate',
      '/usr/local/munki/authrestartd',
      '/usr/local/munki/launchapp',
      '/usr/local/munki/ptyexec',
      '/usr/local/munki/removepackages',
      '/usr/local/munki/supervisor',
    ]
  }

  apple_package { 'munkitools_core':
    source        => $actual_munkitools_core_source,
    version       => $munkitools_core_version,
    receipt       => $munki::munkitools_core_receipt,
    installs      => $munkitools_core_installs,
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

  # Munki 7 moved the app usage binaries under libexec/; Munki 6 keeps them at the
  # top level. The LaunchDaemon/LaunchAgent plists are unchanged between versions.
  if $is_munki7 {
    $munkitools_app_usage_installs = [
      '/Library/LaunchDaemons/com.googlecode.munki.appusaged.plist',
      '/Library/LaunchAgents/com.googlecode.munki.app_usage_monitor.plist',
      '/usr/local/munki/libexec/appusaged',
      '/usr/local/munki/libexec/app_usage_monitor',
    ]
  } else {
    $munkitools_app_usage_installs = [
      '/Library/LaunchDaemons/com.googlecode.munki.appusaged.plist',
      '/Library/LaunchAgents/com.googlecode.munki.app_usage_monitor.plist',
      '/usr/local/munki/appusaged',
      '/usr/local/munki/app_usage_monitor',
    ]
  }

  apple_package { 'munkitools_app_usage':
    source        => $actual_munkitools_app_usage_source,
    version       => $munkitools_app_usage_version,
    receipt       => $munki::munkitools_app_usage_receipt,
    installs      => $munkitools_app_usage_installs,
    force_install => $force_install,
    http_checksum => $munki::munkitools_app_usage_checksum,
    http_username => $munki::http_user,
    http_password => $munki::http_password
  }

  # Munki 7's launchd package adds an authrestartd LaunchDaemon that Munki 6 does
  # not ship.
  if $is_munki7 {
    $munkitools_launchd_installs = [
      '/Library/LaunchDaemons/com.googlecode.munki.managedsoftwareupdate-check.plist',
      '/Library/LaunchDaemons/com.googlecode.munki.managedsoftwareupdate-install.plist',
      '/Library/LaunchDaemons/com.googlecode.munki.managedsoftwareupdate-manualcheck.plist',
      '/Library/LaunchDaemons/com.googlecode.munki.logouthelper.plist',
      '/Library/LaunchDaemons/com.googlecode.munki.authrestartd.plist',
    ]
  } else {
    $munkitools_launchd_installs = [
      '/Library/LaunchDaemons/com.googlecode.munki.managedsoftwareupdate-check.plist',
      '/Library/LaunchDaemons/com.googlecode.munki.managedsoftwareupdate-install.plist',
      '/Library/LaunchDaemons/com.googlecode.munki.managedsoftwareupdate-manualcheck.plist',
      '/Library/LaunchDaemons/com.googlecode.munki.logouthelper.plist',
    ]
  }

  apple_package { 'munkitools_launchd':
    source        => $actual_munkitools_launchd_source,
    version       => $munkitools_launchd_version,
    receipt       => $munki::munkitools_launchd_receipt,
    installs      => $munkitools_launchd_installs,
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
