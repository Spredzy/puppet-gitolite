# Definition: gitolite::instance
#
#   Install a gitolite instance
#
# Parameters:
#
#   [*admin_pub_key*] : The content of the gitolite administrator ssh pub key content
#   [*version*]       : The gitolite version
#   [*user*]          : The gitolite user name
#   [*home*]          : The gitolite base path
#
# Examples:
#
#   gitolite::instance {'me' :
#     admin_pub_key => 'ssh-rsa --THE KEY-- root@localhost',
#   }
#
define gitolite::instance(
  $admin_pub_key,
  $version            = '3.04',
  $user               = $name,
  $home               = "/opt/${name}",
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

  group {$user :
    ensure => present,
  }

  user {$user :
    ensure           => present,
    home             => $home,
    comment          => "gitolite user ${user}",
    gid              => $user,
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
    group   => $user,
    mode    => '0710',
    require => User[$user],
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
    group   => $user,
    mode    => '0700',
    recurse => true,
    require => Exec["cp -r /var/tmp/gitolite-${version} ${home}/gitolite"],
  }

  file {"${home}/${admin_username}.pub" :
    ensure  => present,
    owner   => $user,
    group   => $user,
    mode    => '0700',
    content => $admin_pub_key,
    require => File["${home}/gitolite"],
  }

  file {"${home}/.gitolite.rc" :
    ensure  =>  present,
    content =>  template("gitolite/gitolite-${major_ver}.rc"),
    owner   =>  $user,
    group   =>  $user,
    mode    =>  '0770',
    require =>  File["${home}/${admin_username}.pub"],
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
    group   =>  $user,
    mode    =>  '0600',
    recurse =>  true,
    require =>  Exec["${home}/gitolite/src/gitolite setup -pk ${admin_username}.pub"],
  }

}
