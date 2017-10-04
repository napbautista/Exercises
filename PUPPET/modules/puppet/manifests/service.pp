# == Class: service
#
# Sets a cron for the script (memory_usage.sh) to run every 10 minutes.
#
# === Author
#
# Author Name: Nap Bautista
#
class puppet::service inherits puppet {

cron { 'Memory Usage Check':
	ensure  => present,
	command => "/home/monitor/src/my_memory_check -c 90 -w 60 -e test@email.com >> /home/monitor/memory_check.log 2>&1",
	user    => root,
	minute  => '*/10'
}

}

