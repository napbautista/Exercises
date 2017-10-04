# == Class: install
#
# Installs desired packages. Packages vim, curl, and git satisfies
# the requirement of exercise #2, while wget package is  needed
# by the puppet to work properly. 
#
# === Author
#
# Author Name: Nap Bautista
#
class puppet::install inherits puppet {

package { ['vim', 'curl', 'git', 'wget']:
	ensure => installed,
	allow_virtual => true,
}

}

