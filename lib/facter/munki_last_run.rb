# munki_last_run.rb

# Get the plist dynamically eventually
report_plist = "/Library/Managed Installs/ManagedInstallReport.plist"

Facter.add(:munki_last_run) do
  confine kernel: "Darwin"
  setcode do
    last_run = "never"
    if File.exist?(report_plist)
      require "puppet/util/plist" if Puppet.features.cfpropertylist?
      plist = Puppet::Util::Plist.read_plist_file(report_plist)
      last_run = plist["StartTime"]
    end
    last_run || "never"
  end
end
