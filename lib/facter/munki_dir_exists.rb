# munki_dir_exists.rb
Facter.add(:munki_dir_exists) do
  confine kernel: 'Darwin'
  setcode do
    if File.exist?('/usr/local/munki') && File.exist?('/Applications/Managed Software Center.app')
      true
    else
      false
    end
  end
end
