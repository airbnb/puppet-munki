# munki_last_run_unix.rb

require "time"

Facter.add(:munki_last_run_unix) do
  confine kernel: "Darwin"
  setcode do
    munki_last_run = Facter.value(:munki_last_run)
    if munki_last_run == "never"
      0
    else
      Time.parse(munki_last_run).to_i
    end
  end
end
