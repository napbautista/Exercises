# == Class: config
#
# Creates entites and performs certain functions before the cron in service 
# class is started.  Functions/operations performed by config class includes:
# 
#   - Creation of user account (monitor user)
#   - Creation of directory for the script(/home/monitor/script) 
#     and directory for the link to script(/home/monitor/src)
#   - Download of script from github (memory_usage.sh)
#   - Creation of symbolic link to downloaded script
#   - Setting of timezone(PHT) and hostname(bxp.server.local) of local machine
#  
# === Author
#
# Author Name: Nap Bautista 
#
class puppet::config inherits puppet {

# Create user, password is 'test'
user { 'monitor':  
        ensure   => present,  
        password => '$1$KuQHctMx$oNzzLuG3rGEp25iOU1vj90', 
        home     => '/home/monitor',  
	shell	 => '/bin/bash',
	comment  => '"Test user for puppet exercise"',
	managehome => true,
}

# Create directory of script
file { '/home/monitor/scripts':
	ensure => directory,
	owner => monitor,
	group => monitor,
	before => Exec['Download Script'],
}

# Download script from github
exec { 'Download Script':
	command => 'wget -O memory_check https://raw.githubusercontent.com/napbautista/Exercises/master/BASH/memory_check.sh && chmod u+x memory_check',
    	path    => '/usr/bin/:/bin/',
	cwd     => '/home/monitor/scripts/',
	require => Package['wget']
}

# Create directory of link to the script
file { '/home/monitor/src':
        ensure => directory,
        owner => monitor,
        group => monitor,
}

# Create symbolic link to the script
file { '/home/monitor/src/my_memory_check':
        ensure => 'link',
        target => '/home/monitor/scripts/memory_check',
}

# [BONUS] Set timezone
exec { 'Set Timezone':
	command => 'mv /etc/localtime /etc/localtime.backup && ln -s /usr/share/zoneinfo/Asia/Manila /etc/localtime',
    	path    => '/usr/bin/:/bin/',
}

# [BONUS] Set hostname. Configures /etc/hostname, /etc/hosts, and uses hostname command. 
# Relogin to machine required to see change in display  prompt.
exec { 'Set Hostname':
	command => 'echo "bpx.server.local" > /etc/hostname && hostname bpx.server.local && IP_MASK=`ip a | grep inet | grep eth0 |  awk {\'print $2\'}` && echo ${IP_MASK%???} bpx bpx.server.local >> /etc/hosts',
    	path    => '/usr/bin/:/bin/:/sbin/',
}

}

