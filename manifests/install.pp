# Install munki
class munki::install {

  $munkitools_version = $munki::munkitools_version
  $days_before_broken = $munki::days_before_broken
  $package_source     = $munki::package_source

  validate_integer($days_before_broken)

  if ! defined(File["${facts['puppet_vardir']}/packages"]) {
    file { "${facts['puppet_vardir']}/packages":
      ensure => directory,
    }
  }

  $today = strftime('%s')

  # $today - (86400 seconds in a day * $days_before_broken)
  $broken_days_ago = $today - (86400 * $days_before_broken)

  if $days_before_broken != 0 {
    if ($facts['munki_last_run_unix'] != undef and ($facts['munki_last_run_unix'] < $broken_days_ago or $facts['munki_dir_exists'] == false or $facts['munki_version'] == 'Munki not installed')) or versioncmp($facts['munki_version'], $munkitools_version) < 0{
      # Munki has run before, but it's not run for ages

      # Bin the Puppet receipt
      exec { "/bin/rm -f /var/db/.puppet_pkgdmg_installed_munkitools-${munkitools_version}":
      }

      # Forget the real receipts
      exec {'/usr/sbin/pkgutil --forget com.googlecode.munki.admin':
        returns => [0, 1]
      }

      exec {'/usr/sbin/pkgutil --forget com.googlecode.munki.app':
        returns => [0, 1]
      }

      exec {'/usr/sbin/pkgutil --forget com.googlecode.munki.core':
        returns => [0, 1]
      }

      exec {'/usr/sbin/pkgutil --forget com.googlecode.munki.launchd':
        returns => [0, 1]
      }

    }

  }


  if versioncmp($facts['munki_version'], $munkitools_version) < 0 {
    notify{"${facts['munki_version']} is less than ${munkitools_version}": }
  }

  if macos_package_installed('com.googlecode.munki.core', $munkitools_version) == false or
  $facts['munki_dir_exists'] == false or
  $facts['munki_version'] == 'Munki not installed' or
  versioncmp($facts['munki_version'], $munkitools_version) < 0
  {
    file { "${facts['puppet_vardir']}/packages/munkitools.pkg":
      ensure  => file,
      source  => $package_source,
      mode    => '0644',
      backup  => false,
      require => File["${facts['puppet_vardir']}/packages"],
    }

    package { "munkitools-${munkitools_version}":
      ensure   => installed,
      provider => pkgdmg,
      source   => "${facts['puppet_vardir']}/packages/munkitools.pkg",
      require  => File["${facts['puppet_vardir']}/packages/munkitools.pkg"],
    }
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
