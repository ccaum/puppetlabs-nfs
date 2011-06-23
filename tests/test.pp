exportnfs {'/exports/testa': 
  ensure => present,
  host   => ['hosta','hostb'],
}

exportnfs {'/exports/testd': 
  name   => '/exports/testd',
  ensure => present,
  host   => ['hoste','hostd'],
}


exportnfs {'test2':
  name  => '/exports/testd',
  parameters => ['rw','no_root_squash'],
  host  => 'hostf',
}
