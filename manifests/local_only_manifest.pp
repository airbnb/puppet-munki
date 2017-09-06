# == Class: munki::local_only_manifest
#
class munki::local_only_manifest (
  Array $managed_installs,
  Array $managed_uninstalls,
  String $local_only_manifest_name,
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

  if $managed_installs == [] and $managed_uninstalls == [] {
    $ensure = 'absent'
  } else {
    $ensure = 'present'
  }

  $file_content = {
    'managed_installs'   => $managed_installs,
    'managed_uninstalls' => $managed_uninstalls
  }

  file {"/Library/Managed Installs/manifests/${local_only_manifest_name}":
    ensure  => $ensure,
    mode    => '0644',
    owner   => 0,
    group   => 0,
    content => plist($file_content)
  }
}
