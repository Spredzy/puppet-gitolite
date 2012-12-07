# Class: gitolite
#
#   Ensure the necessary packages are installed for gitolite installation
#
# Parameters:
#
#   [*provider*]            : the method to install git (packages or source)
#   [*git_version*]             : The git version number
#
# Requires:
#
# Examples:
#
#   include gitolite
#
#   class {'gitolite' :
#     provider    => 'source',
#     git_version => '1.8.0',
#   }
#
class gitolite (
  $provider     => 'package',
  $git_version  =>  '1.7.1') {


  case $provider {
    'package' : { require git }
    'source' : {
      class {'git' :
        provider => 'source',
        version  => $git_version,
      }
    }
  }

  if $::osfamily == 'RedHat' {

    package {'perl-Time-HiRes' :
      ensure => latest,
    }

  }

}

