# Class: gitolite
#
# This class install gitolite and a gitolite-admin account
#
#
class gitolite () {

  require git, devtools

  if $::osfamily == 'RedHat' {

    package {'perl-Time-HiRes' :
      ensure => latest,
    }

  }

}

