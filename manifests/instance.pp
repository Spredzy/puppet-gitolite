# Definition: gitolite::instance
#
#   Install a gitolite instance
#
# Parameters:
#
#   [*admin_pub_key*]       : The content of the gitolite administrator ssh pub key content
#   [*version*]             : The gitolite version
#   [*user*]                : The gitolite user name
#   [*group*]               : The gitolite group name
#   [*home*]                : The gitolite base path
#   [*key_store*]           : The gitolite ssh key storage
#   [*home_chmod*]          : The gitolite home directory chmod
#   [*gitolite_chmod*]      : The gitolite directory chmod
#   [*key_store_chmod*]     : The gitolite key store directory chmod
#   [*admin_pub_key_chmod*] : The gitolite admin public ssh key file chmod
#   [*gitoliterc_chmod*]    : The gitolite gitolite.rc file chmod
#
# Examples:
#
#   gitolite::instance {'me' :
#     admin_pub_key => 'ssh-rsa --THE KEY-- root@localhost',
#   }
#
define gitolite::instance(
  $admin_pub_key,
  $version             = '3.5.2',
  $user                = $name,
  $group               = $name,
  $home                = "/opt/${user}",
  $key_store           = $home,
  $home_chmod          = '0700',
  $gitolite_chmod      = '0700',
  $repositories_chmod  = '0700',
  $key_store_chmod     = '0700',
  $admin_pub_key_chmod = '0700',
  $gitoliterc_chmod    = '0700',
) {

  require gitolite

  $admin_username = get_username($admin_pub_key)
  $major_ver = get_first_part($version, '.')

  exec {"curl -L https://github.com/sitaramc/gitolite/archive/v${version}.tar.gz  | tar -xzf - && cd gitolite-${version}" :
    cwd       =>  '/var/tmp',
    user      =>  'root',
    path      =>  ['/usr/local/bin', '/bin', '/usr/bin'],
    timeout   =>  0,
    logoutput =>  on_failure,
    unless    =>  "ls /var/tmp/gitolite-${version}",
  }

  group {$group :
    ensure => present,
  }

  user {$user :
    ensure           => present,
    home             => $home,
    comment          => "gitolite user ${user}",
    gid              => $group,
    shell            => "/bin/sh",
    password_min_age => '0',
    password_max_age => '99999',
    password         => '*',
  }

  $h = get_cwd_hash_path($home, $user)
  create_resources('file', $h)

  file {$home :
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => $home_chmod,
    require => [User[$user], Group[$group]],
  }

  exec {"cp -r /var/tmp/gitolite-${version} ${home}/gitolite" :
    cwd       => '/',
    user      => 'root',
    path      => '/bin',
    logoutput => on_failure,
    unless    => "ls ${home}/gitolite",
    require   => [File[$home], Exec["curl -L https://github.com/sitaramc/gitolite/archive/v${version}.tar.gz  | tar -xzf - && cd gitolite-${version}"]]
  }

  file {"${home}/gitolite":
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => $gitolite_chmod,
    recurse => true,
    require => Exec["cp -r /var/tmp/gitolite-${version} ${home}/gitolite"],
  }

  file {"${home}/repositories":
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => $repositories_chmod,
    recurse => true,
    require => Exec["cp -r /var/tmp/gitolite-${version} ${home}/gitolite"],
  }

  file {"${home}/${admin_username}.pub" :
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => $admin_pub_key_chmod,
    content => $admin_pub_key,
    require => File[$home],
  }

  file {"${home}/.gitolite.rc" :
    ensure  =>  present,
    content =>  template("gitolite/gitolite-${major_ver}.rc"),
    owner   =>  $user,
    group   =>  $group,
    mode    =>  $gitoliterc_chmod,
    require =>  File["${key_store}/${admin_username}.pub"],
  }

 exec {"${home}/gitolite/src/gitolite setup -pk ${admin_username}.pub" :
    user        => $user,
    cwd         => $home,
    environment => ["HOME=${home}"],
    path        => ['/usr/bin', '/bin'],
    logoutput   => on_failure,
    require     => File["${home}/.gitolite.rc"],
  }

  file {"${home}/.ssh" :
    ensure  =>  present,
    owner   =>  $user,
    group   =>  $group,
    mode    =>  '0600',
    recurse =>  true,
    require =>  Exec["${home}/gitolite/src/gitolite setup -pk ${admin_username}.pub"],
  }

}
