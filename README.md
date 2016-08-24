# puppet-munki

This module configures a Munki client.

## Configuring with Hiera

``` yaml
---
classes:
 - munki

munki::use_client_cert: false
munki::software_repo_url: "https://munki.example.com"
munki::additional_http_headers: ['Authorization: Basic abc12345==']
munki::package_source: "puppet:///modules/a_module_with_munkis_pkg/munkitools.pkg"
```

## Configuring directly in Puppet

``` puppet
class {'munki':
    use_client_cert         => false,
    software_repo_url       => "https://munki.example.com",
    additional_http_headers => ['Authorization: Basic abc12345=='],
    package_source          => "puppet:///modules/a_module_with_munkis_pkg/munkitools.pkg"
}
```

## Installing Munki
It is recommended that you use Puppet's file server to deploy the package via your own module. It only needs to exist in the module's `files` directory to be accessible by other Puppet modules.
