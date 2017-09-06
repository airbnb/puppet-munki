# puppet-munki

This module installs and configures a [Munki client](https://github.com/munki/munki).

## Configuring with Hiera

``` yaml
---
classes:
 - munki

munki::use_client_cert: false
munki::software_repo_url: "https://munki.example.com"
munki::additional_http_headers: ['Authorization: Basic abc12345==']
munki::package_source: "puppet:///modules/a_module_with_munkis_pkg/munkitools.pkg"
munki::days_before_broken: 14
```

## Configuring directly in Puppet

``` puppet
class {'munki':
    use_client_cert         => false,
    software_repo_url       => "https://munki.example.com",
    additional_http_headers => ['Authorization: Basic abc12345=='],
    package_source          => "puppet:///modules/a_module_with_munkis_pkg/munkitools.pkg",
    days_before_broken      => 14,
}
```

For all of the configuration options, see `manifests/init.pp`. Most options correlate directly with their equivalent Munki preference.

## Options that aren't Munki options

### auto_run_after_install

This will deploy a LaunchDaemon that will run `managedsoftwareupdate --auto` once before cleaning up after itself. This will allow Munki to begin it's run during your Puppet run without blocking the rest of your Puppet config.

### payload_organization

The organization that is displayed in the configuration profile.

### days_before_broken

The number of days since the last successful run after which Munki is considered 'broken' and will be reinstalled.

### munkitools_version

The version of Munki you wish to install. This is the output of `managedsoftwareupdate --version`.

### package_source

The path to the install package on your Puppet server. Defaults to `puppet:///modules/bigfiles/munki/munkitools-${munkitools_version}.pkg`, which means that the install package should be in the `bigfiles` module, in `files/munki`, named to match the version.

### local_only_manifest_name

This is the file name of the local manifest. This defaults to `extra_packages`, so if you have a manifest called this on your server, you should change it to something unique.

## Local managed_installs and managed_uninstalls

This module is able to make use of local only manifests, which allows you to use Hiera to assign software to your nodes. As this composites the configuration from all levels of your hierarchy via the `lookup` function, you _must_ use Hiera (rather than Puppet code directly) to configure this.

``` yaml data/serial_number/YOURSERIALNUMBER.yaml
munki::managed_installs:
 - 'windows10_vm'

 munki::managed_uninstalls:
  - 'AdobeFlashPlayer'
 ```

 Using the `lookup` function allows you to specify managed installs and uninstalls at different places in your hierarchy, so for example, you can specify installs for all of your machines using something like the below:

 ``` yaml data/osfamily/Darwin.yaml
 munki::managed_installs:
  - 'GoogleChrome'
```

And then configuring a one off install for a particular machine:

``` yaml data/serial_number/ABC123.yaml
munki::managed_installs:
 - 'Firefox'
```

Which would produce a local client manifest for the machine with the serial number ABC123 of:

``` xml /Library/Managed Installs/manifests/extra_packages
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>managed_installs</key>
    <array>
      <string>windows10_vm</string>
    </array>
    <key>managed_uninstalls</key>
    <array/>
  </dict>
</plist>
```

 ## Requirements

 * [apple_package](https://github.com/macadmins/puppet-apple_package)
 * [client_stdlib](https://github.com/macadmins/puppet-client_stdlib)
 * [stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)
 * [mac_profiles_handler](https://github.com/keeleysam/puppet-mac_profiles_handler)
