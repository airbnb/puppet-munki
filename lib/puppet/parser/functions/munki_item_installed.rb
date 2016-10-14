#
# munki_item_installed
#

module Puppet::Parser::Functions
  newfunction(:munki_item_installed, type: :rvalue, doc: 'Returns true if Munki thinks the item is installed.') do |args|
    raise(Puppet::ParseError, 'munki_item_installed(): ' \
    "Wrong number of arguments given (#{args.size} for 1)") if args.size != 1

    munki_managed_installs = lookupvar('munki_managed_installs')
    # Nothing in here, return false
    return false if munki_managed_installs.size.zero?

    if munki_managed_installs.include? args[0]
      # If a version has been specified, make sure it's that version installed
      return munki_managed_installs[args[0]]['installed']
    end

    # If we're here, it's not installed, return false
    return false
  end
end
