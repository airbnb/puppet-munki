# Install munki
class munki::install {

  $munkitools_version = $munki::munkitools_version
  $days_before_broken = $munki::days_before_broken
  $package_source     = $munki::package_source

  # validate_integer($days_before_broken)

  if ! defined(File["${facts['puppet_vardir']}/packages"]) {
    file { "${facts['puppet_vardir']}/packages":
      ensure => directory,
    }
  }

  $today = strftime('%s')

  # $today - (86400 seconds in a day * $days_before_broken)
  $broken_days_ago = $today - (86400 * $days_before_broken)

  if $facts['munki_last_run_unix'] != undef and $facts['munki_last_run_unix'] < $broken_days_ago {
    $force_install = true
  } elsif (macos_package_installed('com.googlecode.munki.core', $munkitools_version) == false or 
  $facts['munki_dir_exists'] == false or
  $facts['munki_version'] == 'Munki not installed' or
  versioncmp($facts['munki_version'], $munkitools_version) < 0) and
  $facts['munki_running'] == false {
    $force_install = true
  } else {
    $force_install = false
  }

  apple_package { 'munkitools':
    source        => $package_source,
    version       => $munkitools_version,
    receipt       => 'com.googlecode.munki.core',
    installs      => ['/Applications/Managed Software Center.app/Contents/MacOS/Managed Software Center', '/usr/local/munki/managedsoftwareupdate'],
    force_install => $force_install
  }

  # Make sure everything is owned by root
  if $facts['munki_dir_exists'] == true {
    file {'/usr/local/munki':
      owner   => 'root',
      group   => 'wheel',
      recurse => true,
    }
  }

}
