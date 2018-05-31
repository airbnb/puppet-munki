# Ensure munki's services are running
class munki::service {

  $post_v3_agents_cmd = '# get console UID
  consoleuser=`/usr/bin/stat -f "%Su" /dev/console | /usr/bin/xargs /usr/bin/id -u`

  /bin/launchctl bootout gui/$consoleuser /Library/LaunchAgents/com.googlecode.munki.ManagedSoftwareCenter.plist
  /bin/launchctl bootout gui/$consoleuser /Library/LaunchAgents/com.googlecode.munki.MunkiStatus.plist
  /bin/launchctl bootout gui/$consoleuser /Library/LaunchAgents/com.googlecode.munki.managedsoftwareupdate-loginwindow.plist
  /bin/launchctl bootout gui/$consoleuser /Library/LaunchAgents/com.googlecode.munki.munki-notifier.plist
  /bin/launchctl bootstrap gui/$consoleuser /Library/LaunchAgents/com.googlecode.munki.ManagedSoftwareCenter.plist
  /bin/launchctl bootstrap gui/$consoleuser /Library/LaunchAgents/com.googlecode.munki.MunkiStatus.plist
  /bin/launchctl bootstrap gui/$consoleuser /Library/LaunchAgents/com.googlecode.munki.managedsoftwareupdate-loginwindow.plist
  /bin/launchctl bootstrap gui/$consoleuser /Library/LaunchAgents/com.googlecode.munki.munki-notifier.plist

  exit 0'

  service { 'com.googlecode.munki.managedsoftwareupdate-check':
    ensure => 'running',
    enable => true,
  }

  service { 'com.googlecode.munki.managedsoftwareupdate-install':
    ensure => 'running',
    enable => true,
  }

  -> service { 'com.googlecode.munki.managedsoftwareupdate-manualcheck':
    ensure => 'running',
    enable => true,
  }

  if versioncmp($facts['munki_version'], '3.3.0') >= 0 {
    service { 'com.googlecode.munki.appusaged':
      ensure  => 'running',
      enable  => true,
      require => Service['com.googlecode.munki.managedsoftwareupdate-manualcheck']
    }

    -> exec { 'munki_reload_launchagents':
      command     => $post_v3_agents_cmd,
      path        => '/bin:/sbin:/usr/bin:/usr/sbin',
      provider    => 'shell',
      refreshonly => true,
      notify      => Exec['munki_app_usage_agent']
    }

    -> exec {'munki_app_usage_agent':
      command     => '# get console UID
  consoleuser=`/usr/bin/stat -f "%Su" /dev/console | /usr/bin/xargs /usr/bin/id -u`

  /bin/launchctl bootout gui/$consoleuser /Library/LaunchAgents/com.googlecode.munki.app_usage_monitor.plist
  /bin/launchctl bootstrap gui/$consoleuser /Library/LaunchAgents/com.googlecode.munki.app_usage_monitor.plist

  exit 0',
      path        => '/bin:/sbin:/usr/bin:/usr/sbin',
      provider    => 'shell',
      refreshonly => true,
    }

    exec {'munki unload old app usgae':
      command     => '/bin/launchctl unload /Library/LaunchDaemons/com.googlecode.munki.app_usage_monitor.plist
      exit 0',
      provider    => 'shell',
      refreshonly => true,
      before      => File['/Library/LaunchDaemons/com.googlecode.munki.app_usage_monitor.plist']
    }

    -> file {'/Library/LaunchDaemons/com.googlecode.munki.app_usage_monitor.plist':
      ensure => absent
    }

  }

  elsif versioncmp($facts['munki_version'], '3.0.0') >= 0 {
    service { 'com.googlecode.munki.app_usage_monitor':
      ensure  => 'running',
      enable  => true,
      require => Service['com.googlecode.munki.managedsoftwareupdate-manualcheck']
    }

    -> exec { 'munki_reload_launchagents':
      command     => $post_v3_agents_cmd,
      path        => '/bin:/sbin:/usr/bin:/usr/sbin',
      provider    => 'shell',
      refreshonly => true,
    }
  } else {
    exec { 'munki_reload_launchagents':
      command     => '# get console UID
  consoleuser=`/usr/bin/stat -f "%Su" /dev/console | /usr/bin/xargs /usr/bin/id -u`

  /bin/launchctl bootout gui/$consoleuser /Library/LaunchAgents/com.googlecode.munki.ManagedSoftwareCenter.plist
  /bin/launchctl bootout gui/$consoleuser /Library/LaunchAgents/com.googlecode.munki.MunkiStatus.plist
  /bin/launchctl bootout gui/$consoleuser /Library/LaunchAgents/com.googlecode.munki.managedsoftwareupdate-loginwindow.plist
  /bin/launchctl bootstrap gui/$consoleuser /Library/LaunchAgents/com.googlecode.munki.ManagedSoftwareCenter.plist
  /bin/launchctl bootstrap gui/$consoleuser /Library/LaunchAgents/com.googlecode.munki.MunkiStatus.plist
  /bin/launchctl bootstrap gui/$consoleuser /Library/LaunchAgents/com.googlecode.munki.managedsoftwareupdate-loginwindow.plist

  exit 0',
      path        => '/bin:/sbin:/usr/bin:/usr/sbin',
      provider    => 'shell',
      refreshonly => true,
      require     => Service['com.googlecode.munki.managedsoftwareupdate-manualcheck']
    }
  }

}
