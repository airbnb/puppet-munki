# munki_last_run_unix.rb

require 'puppet'
require 'puppet/util/plist' if Puppet.features.cfpropertylist?
require 'time'

# Get the plist dynamically eventually
report_plist = '/Library/Managed Installs/ManagedInstallReport.plist'

Facter.add(:munki_last_run_unix) do
  confine kernel: 'Darwin'
  setcode do
    if File.exist?(report_plist)
      plist = Puppet::Util::Plist.read_plist_file(report_plist)
      Time.parse(plist['StartTime']).to_i
    end
  end
end
