# == Define: Pool_Account
#  A defined type for managing grid pool accounts
#
# == Information
# https://twiki.cern.ch/twiki/bin/view/FIOgroup/PoolAccountEcosystem
#
# === Examples
#
#  pool_account { 'cmspil111':
#    home_dir      => '/home/cmspil111',
#    uuid          => 80111,
#    primary_group => 'cmspilot',
#    groups        => [ 'cms'],
#  }
define grid_pool_accounts::pool_account (
  $username                = $title,
  $password                = '*NP*',
  $shell                   = '/bin/bash',
  $manage_home             = true,
  $home_dir                = "/home/${title}",
  $primary_group           = undef,
  $uid                     = undef,
  $groups                  = [],
  $ensure                  = 'present',
  $comment                 = "mapped user for group ${title}",
  $gridmapdir              = undef,
) {
  case $ensure {
    'present': {
      $dir_ensure = 'directory'
      $dir_owner  = $username
      $dir_group  = $primary_group
      if $primary_group {
        Group[$primary_group] -> User[$title]
      }
    }
    'absent': {
      $dir_ensure = 'absent'
      $dir_owner  = undef
      $dir_group  = undef
    }
    default : {
      err("Invalid value given for ensure: ${ensure}. Must be one of present,absent."
      )
    }
  }

  user { $title:
    ensure     => $ensure,
    name       => $username,
    comment    => $comment,
    uid        => $uid,
    password   => $password,
    shell      => $shell,
    gid        => $primary_group,
    groups     => $groups,
    home       => $home_dir,
    managehome => $manage_home,
  }

  if $gridmapdir {
    file { "${gridmapdir}/${title}":
      ensure  => $ensure,
      require => File[$gridmapdir],
    }
  }
}
