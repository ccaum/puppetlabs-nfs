class nfs::config::defaults {

	#The header for the exports file, where applicable
	$header = "# This file is managed by puppet
#	Manual modification is possible but not recommended
"

	#The directory that the exports fragments are located in
	$work_directory = '/etc/exports.d'

	#Determines the ensure value of the nfsd service
	$service_ensure = running

	#Determines the enable value of ther nfsd service
	$service_enable = true

	#User to own files as
	$file_owner = root

	#Group to own files as
	$file_group = $operatingsystem ? {
		darwin  => wheel,
		default => root
	}

	#Which package to install
	$linux_package = $operatingsystem ? {
		/(ubuntu|debian)/ => 'nfs-kernel-server',
		default           => 'nfs-utils'
	}

	#Which package version to install
	#Default to 'installed' and allow users to specify version number
	# 	through use of the nfs::config parameterized class
	$linux_package_version = 'installed'

	$nfs_service = $operatingsystem ? {
		/(ubuntu|debian)/ => 'nfs-kernel-server',
		/(redhat|centos)/ => 'nfs',
		darwin            => 'com.apple.nfsd'
	}
	
}
