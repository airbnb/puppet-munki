# munki_managed_installs.rb

report_plist = '/Library/Managed Installs/ManagedInstallReport.plist'

Facter.add(:munki_managed_installs) do
  confine kernel: 'Darwin'
  setcode do
    require 'puppet/util/plist' if Puppet.features.cfpropertylist?
    output = {}
    if File.exist?(report_plist)
      plist = Puppet::Util::Plist.read_plist_file(report_plist)
      if plist.include? 'ManagedInstalls'
        plist['ManagedInstalls'].each do |install|
          # This was added in Munki 2.8, handle that
          installed_version = if install.include? 'installed_version'
                                install['installed_version']
                              else
                                'unknown'
                              end
          output[install['name']] = {
            'display_name' => install['display_name'],
            'name'              => install['name'],
            'installed'         => install['installed'],
            'installed_size'    => install['installed_size'],
            'installed_version' => installed_version
          }
        end
      end
    end

    output
  end
end
