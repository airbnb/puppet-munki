# Install munki
class munki::install {

  $munkitools_version = $munki::munkitools_version
  $days_before_broken = $munki::days_before_broken
  $package_source     = $munki::package_source

  if $munki::use_aio {
    include munki::install_aio
  }
  else{
    include munki::install_components
  }

  if $facts['munki_dir_exists'] == false {
    # Kick of a run if needed
    class { '::munki::auto_run': }
  }

  # Make sure everything is owned by root
  if $facts['munki_dir_exists'] == true {
    file {'/usr/local/munki':
      owner     => 'root',
      group     => 'wheel',
      recurse   => true,
      max_files => -1,
    }
  }

}
