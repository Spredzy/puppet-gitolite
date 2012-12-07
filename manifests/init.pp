# Class: gitolite
#
#   Ensure the necessary packages are installed for gitolite installation
#
# Parameters:
#
# Requires:
#
# Examples:
#
#   include gitolite
#
class gitolite () {

  require git, devtools

  if $::osfamily == 'RedHat' {

    package {'perl-Time-HiRes' :
      ensure => latest,
    }

  }

}

