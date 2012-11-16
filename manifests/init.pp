# Class: gitolite
#
# This class install gitolite and a gitolite-admin account
#
#
class gitolite (
  $gitolite_admin_user = $git::params::gitolite_admin_user,
  $home_gitolite_admin_user = $git::params::home_gitolite_admin_user) inherits git::params {

  # IF osfamily is RedHat
  #Class['epel'] -> Class['git'] -> Class['gitolite']
  #class {'epel' :
  #}
  # ELSE
  Class['git'] -> Class['gitolite']

  # TODO: Change default protocol from ssh to none on git module
  #class {'git' :
  #  protocol : 'none';
  #}
  
  # TODO :
  # Parametertriz $HOME for both gitolite and gitolite_admin_user
  # 

  class {'git':
  }

  package {'gitolite' :
    ensure => latest,
  }

  group {$gitolite_admin_user :
    ensure => present,
  }

  user {$gitolite_admin_user :
    ensure           => present,
    home             => $home_gitolite_admin_user,
    comment          => "The ${gitolite_admin_user} user",
    gid              => $gitolite_admin_user,
    groups           => 'gitolite',
    shell            => '/bin/bash',
    password_min_age => '0',
    password_max_age => '99999',
    password         => '*',
    require          => Package['gitolite'],
  }

  user {'gitolite' :
    ensure  => present,
    groups  => $gitolite_admin_user,
    require => User[$gitolite_admin_user],
  }


  file {$home_gitolite_admin_user :
    ensure  => directory,
    group   => $gitolite_admin_user,
    owner   => $gitolite_admin_user,
    mode    => '0700',
    require => User[$gitolite_admin_user],
  }

  file {"${home_gitolite_admin_user}/.gitconfig" :
    ensure  => present,
    content =>  template('gitolite/gitconfig.erb'),
    owner   =>  $gitolite_admin_user,
    group   =>  $gitolite_admin_user,
    mode    =>  '0700',
    require =>  File[$home_gitolite_admin_user],
  }

  exec {"ssh-keygen -N '' -f ${home_gitolite_admin_user}/.ssh/id_rsa" :
    cwd     =>  $home_gitolite_admin_user,
    user    =>  $gitolite_admin_user,
    path    =>  ['/bin', '/usr/bin'],
    require =>  File[$home_gitolite_admin_user],
    unless  =>  "ls ${home_gitolite_admin_user}/.ssh/id_rsa.pub",
  }

 exec {"cp ${home_gitolite_admin_user}/.ssh/id_rsa.pub /var/lib/gitolite/${gitolite_admin_user}.pub" :
    cwd     =>  '/',
    path    =>  '/bin',
    unless  =>  "ls /var/lib/gitolite/${gitolite_admin_user}.pub",
    require =>  [Exec["ssh-keygen -N '' -f ${home_gitolite_admin_user}/.ssh/id_rsa"], Package['gitolite']],
  }

 file {"/var/lib/gitolite/${gitolite_admin_user}.pub" :
   ensure	=>	present,
   owner	=>	'gitolite',
   group 	=>	'gitolite',
   mode		=>	'0700',
   require	=>	Exec["cp ${home_gitolite_admin_user}/.ssh/id_rsa.pub /var/lib/gitolite/${gitolite_admin_user}.pub"],
 }

  file {'/var/lib/gitolite/.gitolite.rc' :
    ensure  => present,
    content => template('gitolite/gitolite.rc'),
    owner  =>  'gitolite',
    group   =>  'gitolite',
    mode    =>  '0700',
    require => File["/var/lib/gitolite/${gitolite_admin_user}.pub"],
  }

 exec {"gl-setup ${gitolite_admin_user}.pub" :
    user  => 'gitolite',
    cwd   => '/var/lib/gitolite/',
    environment	=> ['HOME=/var/lib/gitolite'],
    path  => ['/usr/bin', '/bin'],
    logoutput	=>	true,
    require	=> File['/var/lib/gitolite/.gitolite.rc'],
  }

}
