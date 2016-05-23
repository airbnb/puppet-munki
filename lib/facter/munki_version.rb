#munki_version.rb
Facter.add(:munki_version) do
  confine :kernel => "Darwin"
  setcode do
    if File.exist?('/usr/local/munki/managedsoftwareupdate')
        Facter::Util::Resolution.exec("/usr/local/munki/managedsoftwareupdate --version")
    else
        "Munki not installed"
    end
  end
end
