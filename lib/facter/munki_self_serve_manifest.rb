# munki_self_serve_manifest.rb

# Get the plist dynamically eventually
self_serve_manifest = '/Library/Managed Installs/manifests/SelfServe'

Facter.add(:munki_last_run) do
  confine kernel: 'Darwin'
  setcode do
    if File.exist?(self_serve_manifest)
      require 'puppet/util/plist' if Puppet.features.cfpropertylist?
      plist = Puppet::Util::Plist.read_plist_file(self_serve_manifest)
      managed_installs = plist['mangaged_installed']
      managed_installs
    end
  end
end
