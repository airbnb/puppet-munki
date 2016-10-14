# munki_last_run.rb
require 'puppet/util/plist' if Puppet.features.cfpropertylist?

# Get the plist dynamically eventually
report_plist = '/Library/Managed Installs/ManagedInstallReport.plist'

Facter.add(:munki_last_run) do
  confine kernel: 'Darwin'
  setcode do
    if File.exist?(report_plist)
      plist = Puppet::Util::Plist.read_plist_file(report_plist)
      last_run = plist['StartTime']
    else
      'never'
    end
  end
end
