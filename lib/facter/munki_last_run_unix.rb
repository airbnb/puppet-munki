# munki_last_run_unix.rb

require "time"

Facter.add(:munki_last_run_unix) do
  confine kernel: "Darwin"
  setcode do
    last_run = 0
    munki_last_run = Facter.value(:munki_last_run)
    if munki_last_run == "never"
      last_run = 0
    else
      last_run = Time.parse(munki_last_run).to_i
    end
    last_run || 0
  end
end
