# == Class: puppet
#
# Declares three classes, namely:
#   
#   - install 
#   - config
#   - service
#
# === Author
#
# Author Name: Nap Bautista 

class puppet {
    include puppet::install
    include puppet::config
    include puppet::service
}


