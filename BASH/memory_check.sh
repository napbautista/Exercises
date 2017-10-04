#!/bin/bash

# FUNCTION(S)
user_instruction_func()
{
    echo -e "\nPlease supply complete/correct options and parameters."
    echo "Example: /memory_check.sh -c 90 -w 60 -e useremail@mail.com"
    echo "Options:"
    echo "    -c  critical threshold (%)"
    echo "    -w  Warning threshold (%)"
    echo -e "    -e  user email\n"
    exit 4
}

# Checks and installs pre-requisite package(s) before running script
install_packages_func()
{
    # Loop through all needed packages
    for package in bc mailx
    do
        # Check if package is installed in the system, install if not present
        rpm -q $package > /dev/null 2>&1
        if [ $? -eq 1 ] ; then
            echo -n "Installing $package package at first run..."
            yum install -y $package > /dev/null 2>&1
            echo "installed $package package."
        fi
    done
}

# MAIN

# States date and time in display and marks the start time in the log
echo  "--------------------" 
echo  "`date '+20%y/%m/%d %H:%M:%S'`:" 

# Install pre-requisite package (not included in minimum CentOS installation)
install_packages_func

# COMMAND-LINE OPTIONS. Inform user for invalid options and missing argument.
while getopts ":c:w:e:" opt; do
  case $opt in
    c)
      critical_thold=$OPTARG
      ;;
    w)
      warning_thold=$OPTARG
      ;;
    e)
      user_email=$OPTARG
      ;;
    \?)
      echo -e "\nInvalid option: -$OPTARG" 
      user_instruction_func
      ;;
    :)
      echo -e "\nOption -$OPTARG requires an argument."
      user_instruction_func
      ;;
  esac
done

# Check if all options are supplied, if not, inform user of correct format.
if [ -z $critical_thold ] || [ -z $warning_thold ] || [ -z $user_email ] ; then

    # Further checking may fall here depending on additional requirements 
    #   - disallow characters for -c and -w
    #   - accept only valid email, 
    #   - check of too much arguments
    #   - detect/check duplicate options
    #   - etc ...

    user_instruction_func
else
    # if warning threshold is greater than or equal to critical threshold, inform user 
    if (( $(echo "$warning_thold >= $critical_thold" | bc -l) )); then
        echo "Critical threshold(-c) should always be greater than warning threshold(-w)."
        exit 5
    fi

    # get used and total memory
    used_mem=`free | grep Mem: | awk '{print $3}'`
    total_mem=`free | grep Mem: | awk '{print $2}'`

    # compute memory usage (%)
    calc(){ awk "BEGIN { print "$*" }"; }	# enable calculator
    mem_usage=`calc $used_mem/$total_mem*100`	# compute memory usage
    mem_usage_final=`printf "%0.2f" $mem_usage` # round computed value
    
    # check and display memory usage status base on the range of user input(-c, -w) and computed memory usage
    if (( $(echo "$mem_usage_final >= $critical_thold" | bc -l) )); then
        echo "Memory usage is CRITICAL. Email has been sent to user."

	# send notification to user
	ps aux --sort=-rss | awk {'print $2, $4, $11'} | head -n 11 > email_critical_tmp.txt	# get top 10 most memory-intensive processes
	email_title=`echo "$(date '+20%y%m%d %H:%M') Memory Check - CRITICAL"`			# format email title
	mail -s "$email_title" "$user_email" < ./email_critical_tmp.txt		# mail to user
	rm -rf email_critical_tmp.txt								# clean up temporary file
	exit 2
    elif (( $(echo "$mem_usage_final >= $warning_thold && $mem_usage_final < $critical_thold"  | bc -l) )); then
        echo "Memory usage is WARNING."
	exit 1
    elif (( $(echo "$mem_usage_final < $warning_thold" | bc -l) )); then
	echo "Memory usage is NORMAL."
	exit 0
    else
	echo "Memory usage: UNKNOWN ERROR."
	exit 3
    fi
fi

