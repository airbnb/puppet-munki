# Ensure munki's services are running
class munki::service {

  service { 'com.googlecode.munki.managedsoftwareupdate-check':
    ensure => 'running',
    enable => true,
  }

  service { 'com.googlecode.munki.managedsoftwareupdate-install':
    ensure => 'running',
    enable => true,
  }

  service { 'com.googlecode.munki.managedsoftwareupdate-manualcheck':
    ensure => 'running',
    enable => true,
  }

}
