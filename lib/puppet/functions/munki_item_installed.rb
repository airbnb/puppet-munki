Puppet::Functions.create_function(:munki_item_installed) do
  dispatch :munki_item_installed do
    required_param "String", :munki_item
  end

  def munki_item_installed(munki_item)
    munki_managed_installs = Facter.value("munki_managed_installs")
    # Nothing in here, return false
    return false if munki_managed_installs.nil? || munki_managed_installs.size.zero?

    if munki_managed_installs.include? munki_item
      # If a version has been specified, make sure it's that version installed
      return munki_managed_installs[munki_item]["installed"]
    end

    # If we're here, it's not installed, return false
    return false
  end
end
