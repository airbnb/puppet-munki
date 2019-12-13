class munki::install_aio {
  $package_source = $munki::package_source
  $munkitools_source = $munki::munkitools_source
  $munkitools_version = $munki::munkitools_version

  if $package_source != '' {
    $actual_package_source = $package_source
  } elsif $munkitools_source != '' {
    $actual_package_source = $munkitools_source
  } else {
    $actual_package_source = "puppet:///modules/bigfiles/munki/munkitools-${munkitools_version}.pkg"
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
  versioncmp($facts['munki_version'], $munkitools_version) < 0) and
  $facts['munki_running'] == false {
    $force_install = true
    exec {'forget_munki_pkgs':
      command => '/bin/rm -rf /usr/local/munki/munkilib
      /usr/sbin/pkgutil --forget com.googlecode.munki.admin
      /usr/sbin/pkgutil --forget com.googlecode.munki.app
      /usr/sbin/pkgutil --forget com.googlecode.munki.core
      /usr/sbin/pkgutil --forget com.googlecode.munki.launchd
      /usr/sbin/pkgutil --forget com.googlecode.munki.app_usage
      /usr/sbin/pkgutil --forget com.googlecode.munki.python
      exit 0',
      before  => Apple_package['munkitools']
    }
  } else {
    $force_install = false
  }

  apple_package { 'munkitools':
    source        => $actual_package_source,
    version       => $munkitools_version,
    receipt       => 'com.googlecode.munki.core',
    installs      => ['/Applications/Managed Software Center.app/Contents/MacOS/Managed Software Center', '/usr/local/munki/managedsoftwareupdate'], # lint:ignore:140chars
    force_install => $force_install,
    notify        => [
      Exec['munki_reload_launchagents'],
      Service['com.googlecode.munki.managedsoftwareupdate-check'],
      Service['com.googlecode.munki.managedsoftwareupdate-install'],
      Service['com.googlecode.munki.managedsoftwareupdate-manualcheck']
    ],
    http_checksum => $munki::munkitools_checksum,
    http_username => $munki::http_user,
    http_password => $munki::http_password
  }
}
