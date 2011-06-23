## THESE TESTS MODIFY THE SYSTEM

#fail inline_template("<%= scope.find_resource_type('package').instances.each { |pkg| pkg.currentpropvalues.each{ |prop,value| puts \"#{prop} => #{value}\"} } %>")
#fail inline_template("<%= scope.find_resource_type('package').instances.each { |pkg| puts pkg.name } %>")

Nfs::Exporthost {
  parameters => ['rw','no_root_squash'],
}

# Create our export hosts
nfs::export { 'google.com':
  export => ['/exports/testa','/exports/testd'],
  ro     => true,
  mapall => nobody
}

nfs::export { 'google.com-testc':
  host       => ['google.com','yahoo.com'],
  export     => ['/exports/testc','/exports/testd'],
  parameters => ['ro'],
}

class { 'nfs::config':
   header => "# YO",
   file_group => 'staff',
}
