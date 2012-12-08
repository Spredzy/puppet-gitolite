puppet-gitolite
===============

A Puppet module that install and configure gitolite.

**Note** : As of this writting it does not handle the management of the conf/gitolite.conf file

## Example

### Gitolite

If you are fine with your current package manager git version a simple `include gitolite` will be enough

If you want to have a specific version of git installed on your server the following declaration will meet your need

```
class {'gitolite' :
    git_provider    => 'source',
    git_version => '1.8.0',
}
```

### Gitolite::instance

### Simplest

```
gitolite::instance{'me' :
  admin_pub_key =>  'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3rf0UHUOxfO+XGixNbo6Gq+ysW8JwLBx32iJCCQCvcxJJ1xe+F4LqaRce+o7ikHwuMxevZwJOjBhRBY1xiRIwxt0M/EpHIyDtmwb4MH4meDUId2phyE58othZXyEWnpD59ulcf/xUXAsS9Nsa3ec5UgcMoY9gddz0PqcEfpQV22czD4dNt0zj4xajSu59azwkxQqoy2mFlX0+inWosxDg+OKdjdv1afvzL8UW85KgrjKuZmf8Y2Vgst08odOv/Iqzrg44dmdhEx00VZs8Wnd57vwaKwzV/3dmxjHzuo0Hidt5CzbDQ+oRYcFYv126zubVnwLyQpujNGsE55vhA1i2Q== root@localhost',
}
```

This will download the source of the latest gitolite version and install them on `/opt/me/gitolite` and then configure the installation to have as administrator the ssh pub key passed as parameter.

### Specific

```
gitolite::instance{'me' :
  admin_pub_key =>  'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3rf0UHUOxfO+XGixNbo6Gq+ysW8JwLBx32iJCCQCvcxJJ1xe+F4LqaRce+o7ikHwuMxevZwJOjBhRBY1xiRIwxt0M/EpHIyDtmwb4MH4meDUId2phyE58othZXyEWnpD59ulcf/xUXAsS9Nsa3ec5UgcMoY9gddz0PqcEfpQV22czD4dNt0zj4xajSu59azwkxQqoy2mFlX0+inWosxDg+OKdjdv1afvzL8UW85KgrjKuZmf8Y2Vgst08odOv/Iqzrg44dmdhEx00VZs8Wnd57vwaKwzV/3dmxjHzuo0Hidt5CzbDQ+oRYcFYv126zubVnwLyQpujNGsE55vhA1i2Q== root@localhost',
  version       => '3.04',
  home          => '/home/me',
}
```

This will download the source of the 3.04 gitolite version. Install them in `${home}/gitolite` and then configure the installation to have as administrator the ssh pub key passed as parameter.


## License

GPLv3
