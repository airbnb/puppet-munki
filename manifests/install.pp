# Install munki
class munki::install {

  $munkitools_version = $munki::munkitools_version
  $days_before_broken = $munki::days_before_broken

  validate_integer($days_before_broken)

  if ! defined(File["${::puppet_vardir}/packages"]) {
    file { "${::puppet_vardir}/packages":
      ensure => directory,
    }
  }

  $today = strftime("%s")

  # $today - (86400 seconds in a day * $days_before_broken)
  $broken_days_ago = $today - (86400 * $days_before_broken)

  if $days_before_broken != 0 {
    if ($facts['munki_last_run_unix'] != undef and $facts['munki_last_run_unix'] < $broken_days_ago) or $munki_dir_exists == false {
      # Munki has run before, but it's not run for ages
      
      # Bin the Puppet receipt
      exec { "/bin/rm -f /var/db/.puppet_pkgdmg_installed_munkitools-${munkitools_version}":
      }

      # Forget the real receipts
      exec {'/usr/sbin/pkgutil --forget com.googlecode.munki.admin':
        refreshonly => true,
      } ~>

      exec {'/usr/sbin/pkgutil --forget com.googlecode.munki.app':
        refreshonly => true,
      } ~>

      exec {'/usr/sbin/pkgutil --forget com.googlecode.munki.core':
        refreshonly => true,
      } ~>

      exec {'/usr/sbin/pkgutil --forget com.googlecode.munki.launchd':
        refreshonly => true,
      } ~>

      # Bin the cached copy of the profile so it gets reinstalled
      exec {"/bin/rm -f ${::puppet_vardir}/mobileconfigs/ManagedInstalls":
        refreshonly => true,
      }
    }

  }
  

  if $munki_version == "Munki not installed" {
    file { "${::puppet_vardir}/packages/munkitools.pkg":
      ensure  => file,
      source  => "puppet:///modules/munki/munkitools-${munkitools_version}.pkg",
      mode    => '0644',
      backup  => false,
      require => File["${::puppet_vardir}/packages"],
    }
    package { "munkitools-${munkitools_version}":
      ensure   => installed,
      provider => pkgdmg,
      source   => "${::puppet_vardir}/packages/munkitools.pkg",
      require  => File["${::puppet_vardir}/packages/munkitools.pkg"],
    }
  }

  # Make sure everything is owned by root
  if $munki_dir_exists {
    file {'/usr/local/munki':
      owner   => 'root',
      group   => 'wheel',
      recurse => true,
    }
  }

}