# converts a ruby hash to a plist

require 'puppet/util/plist' if Puppet.features.cfpropertylist?

# The meat
module Puppet::Parser::Functions
  newfunction(:plist, type: :rvalue) do |args|
    hash   = args[0]      || {}
    format = args[1]      || :xml

    return Puppet::Util::Plist.dump_plist(hash, format)
  end
end
