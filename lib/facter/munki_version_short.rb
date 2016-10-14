# munki_version_short.rb
Facter.add(:munki_version_short) do
  confine kernel: 'Darwin'
  setcode do
    munki_version = Facter.value(:munki_version)
    if munki_version == 'Munki not installed'
      'Munki not installed'
    else
      splitsting = munki_version.split('.')
      splitsting[0] + '.' + splitsting[1] + '.' + splitsting[2]
    end
  end
end
