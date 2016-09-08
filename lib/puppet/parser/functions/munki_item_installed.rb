#
# munki_item_installed
#
# require 'puppet/util/package'
require 'puppet/util/plist'

module Puppet::Parser::Functions
  newfunction(:munki_item_installed, type: :rvalue, doc: <<-EOS
Returns true if Munki thinks the item is installed.
    EOS
   ) do |args|

    raise(Puppet::ParseError, 'munki_item_installed(): ' \
    "Wrong number of arguments given (#{args.size} for 1)") if args.size != 1


    munki_managed_installs = lookupvar('munki_managed_installs')
    # Nothing in here, return false
    if munki_managed_installs.size == 0
      return false
    end


    if munki_managed_installs.include? args[0]
      # If a version has been specified, make sure it's that version installed
      if args.size == 2
        if install['version'] == args[1]
          return true
        end
      else
        return true
      end
      # return true
    end

    # If we're here, it's not installed, return false
    return false
  end
end
