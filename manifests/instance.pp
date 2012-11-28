# Definition: gitolite::instance
#
# gitolite::instance{'yanis':
#   home => '/opt/yanis',
#
define gitolite::instance(
  $admin_ssh_key,
  $admin_user,
  $version            = '3.04',
  $admin_ssh_key_type = 'ssh-rsa',
  $user               = $name,
  $home               = "/opt/gitolite-${name}",
) {

  require gitolite

  $admin_username = get_first_part($admin_user, '@')
  $major_ver = get_first_part($version, '.')
  $public_key = join([$admin_ssh_key_type, $admin_ssh_key, $admin_user], " ")

  exec {"curl -L https://github.com/sitaramc/gitolite/archive/v${version}.tar.gz  | tar -xzf - && cd gitolite-${version}" :
    cwd       =>  '/var/tmp',
    user      =>  'root',
    path      =>  ['/usr/local/bin', '/bin', '/usr/bin'],
    timeout   =>  0,
    logoutput =>  on_failure,
    unless    =>  "ls /var/tmp/gitolite-${version}",
  }

  group {"gitolite-${user}" :
    ensure => present,
  }

  user {"gitolite-${user}" :
    ensure           => present,
    home             => $home,
    comment          => "gitolite user gitolite-${user}",
    gid              => "gitolite-${user}",
    shell            => "/bin/sh",
    password_min_age => '0',
    password_max_age => '99999',
    password         => '*',
  }

  $h = get_cwd_hash_path($home, $user)
  create_resources('file', $h)

  file {$home :
    ensure  => directory,
    owner   => "gitolite-${user}",
    group   => "gitolite-${user}",
    mode    => '0700',
    require => User["gitolite-${user}"],
  }

  exec {"cp -r /var/tmp/gitolite-${version} ${home}/gitolite" :
    cwd       => '/',
    user      => 'root',
    path      => '/bin',
    logoutput => on_failure,
    unless    => "ls ${home}/gitolite",
    require   => File[$home],
  }

  file {"${home}/gitolite":
    ensure  => directory,
    owner   => "gitolite-${user}",
    group   => "gitolite-${user}",
    mode    => '0700',
    recurse => true,
    require => Exec["cp -r /var/tmp/gitolite-${version} ${home}/gitolite"],
  }

  file {"${home}/${admin_username}.pub" :
    ensure  => present,
    owner   => "gitolite-${user}",
    group   => "gitolite-${user}",
    mode    => '0700',
    content => $public_key,
    require => File["${home}/gitolite"],
  }

  file {"${home}/.gitolite.rc" :
    ensure  =>  present,
    content =>  template("gitolite/gitolite-${major_ver}.rc"),
    owner   =>  "gitolite-${user}",
    group   =>  "gitolite-${user}",
    mode    =>  '0770',
    require =>  File["${home}/${admin_username}.pub"],
  }

 exec {"${home}/gitolite/src/gitolite setup -pk ${admin_username}.pub" :
    user        => "gitolite-${user}",
    cwd         => $home,
    environment => ["HOME=${home}"],
    path        => ['/usr/bin', '/bin'],
    logoutput   => on_failure,
    require     => File["${home}/.gitolite.rc"],
  }

  file {"${home}/.ssh" :
    ensure  =>  present,
    owner   =>  "gitolite-${user}",
    group   =>  "gitolite-${user}",
    mode    =>  '0600',
    recurse =>  true,
    require =>  Exec["${home}/gitolite/src/gitolite setup -pk ${admin_username}.pub"],
  }

}
