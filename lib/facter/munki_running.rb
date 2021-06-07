# munki_running.rb

Facter.add(:munki_running) do
  confine kernel: "Darwin"
  setcode do
    running = false
    output = Facter::Util::Resolution.exec("/bin/ps -eo pid=,command=")
    output.each_line do |line|
      if line.include? "/usr/bin/python /usr/local/munki/managedsoftwareupdate"
        running = true
        break
      end
    end
    running
  end
end
