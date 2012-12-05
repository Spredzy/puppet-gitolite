# Function: get_username
#
#   Retrieve the username in the SSH public key file
#
#   ie. ssh-rsa YourLongSSHKey root@localdomain    => root
#
module Puppet::Parser::Functions
  newfunction(:get_username, :type => :rvalue) do |args|

  username = args[0].split(' ')[2].split('@')[0]
  username

  end
end
