# munki_version.rb
Facter.add(:munki_version) do
  confine kernel: 'Darwin'
  setcode do
    if File.exist?('/usr/local/munki/managedsoftwareupdate')
      output = Facter::Util::Resolution.exec('/usr/local/munki/managedsoftwareupdate --version')
      if output =~ /^\d+\W\d+\W\d+\W\d+$/
        output
      else
        'Munki not installed'
      end
    else
      'Munki not installed'
    end
  end
end
