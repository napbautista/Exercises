# == Class: puppet_cleanup
#
# Removes resources created by puppet module. E.g. monitor user,
# created directories, packages(vim, wget, curl, git),
# and cron. 
#
# === Author
#
# Author Name Nap Bautista
#
class puppet_cleanup {

# Uninstall packages
package { ['vim', 'wget',]:
	ensure => absent,
	allow_virtual => true,
}

exec { 'Uninstall curl and git(--nodeps)':
	command => 'rpm -e --nodeps curl git',
    	path    => '/usr/bin/:/bin/',
}

# Delete user 'monitor'
user { 'monitor':  
        ensure   => absent,  
	managehome => true,
}

# Delete cron 
cron { 'Memory Usage Check':
	ensure  => absent,
}

# [BONUS] Set timezone
exec { 'Set Timezone':
        command => 'mv /etc/localtime /etc/localtime.backup && ln -s /usr/share/zoneinfo/Europe/Brussels /etc/localtime',
        path    => '/usr/bin/:/bin/',
}

# [BONUS] Set hostname. Set to a different hostname, host.server.local. Relogin to machine required. 
exec { 'Set Hostname':
        command => 'echo "host.server.local" > /etc/hostname && hostname host.server.local && head -n -1 /etc/hosts > temp.txt && mv -f temp.txt /etc/hosts && IP_MASK=`ip a | grep inet | grep eth0 |  awk {\'print $2\'}` && echo ${IP_MASK%???} host host.server.local >> /etc/hosts',
        path    => '/usr/bin/:/bin/:/sbin/',
}

}
