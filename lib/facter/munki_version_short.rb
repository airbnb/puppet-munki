# munki_version_short.rb
Facter.add(:munki_version_short) do
  confine kernel: "Darwin"
  setcode do
    munki_version = Facter.value(:munki_version)
    if munki_version == "Munki not installed"
      0
    else
      munki_version[/^\d+\W\d+\W\d+/]
    end
  end
end
