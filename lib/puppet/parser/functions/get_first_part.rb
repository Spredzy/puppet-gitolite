# Function: get_first_part
#
#    Retrieve the first part of the string relative to the separator
#
#   ie. root@localdomain    => root   (sep: @)
#       3.0.4               => 3      (sep: .)
#
module Puppet::Parser::Functions
  newfunction(:get_first_part, :type => :rvalue) do |args|

    first_part = args[0].split(args[1])[0]
    first_part

  end
end

