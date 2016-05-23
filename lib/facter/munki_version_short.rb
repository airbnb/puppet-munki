#munki_version_short.rb
Facter.add(:munki_version_short) do
  confine :kernel => "Darwin"
  setcode do
    if File.exist?('/usr/local/munki/managedsoftwareupdate')
        fullver = Facter::Util::Resolution.exec("/usr/local/munki/managedsoftwareupdate --version")
        splitsting = fullver.split(".")
        splitsting[0]+"."+splitsting[1]+"."+splitsting[2]
    else
        "Munki not installed"
    end
  end
end
