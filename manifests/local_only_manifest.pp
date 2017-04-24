# == Class: munki::local_only_manifest
#
class munki::local_only_manifest (
  Array $managed_installs,
  Array $managed_uninstalls,
){
  if !defined(File['/Library/Managed Installs']) {
    file { '/Library/Managed Installs':
      ensure => directory,
    }
  }

  if !defined(File['/Library/Managed Installs/manifests']) {
    file { '/Library/Managed Installs/manifests':
      ensure => directory,
    }
  }

  $file_content = {
    'managed_installs'   => $managed_installs,
    'managed_uninstalls' => $managed_uninstalls
  }

  file {'/Library/Managed Installs/manifests/extra_packages':
    ensure  => present,
    mode    => '0644',
    owner   => 0,
    group   => 0,
    content => plist($file_content)
  }
}
