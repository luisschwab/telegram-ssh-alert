#!/bin/bash

# Alerts when an SSH session is initiated on a host via telegram message

chat_id=""
telegram_api_token=""
telegram_api_url="https://api.telegram.org/bot${telegram_api_token}/sendMessage"

only_unauthorized=0  #only triggers a message if login is made from unauthorized address

allowed_subnets="192.168.1.0/24" # change this one
allowed_addresses="192.168.1.1 192.168.1.2" # and also this one

server_hostname=$(hostname -f)
server_address=$(hostname -I | awk '{print $1}')
client_username=$(whoami) 
client_address=$(echo $SSH_CLIENT | awk '{print $1}')

login_date=$(date -u +'%F')
login_time=$(date -u +'%T')" UTC"


# snatched this function from https://unix.stackexchange.com/a/465372/
function in_subnet () {
    local ip ip_a mask netmask sub sub_ip rval start end

    # Define bitmask.
    local readonly BITMASK=0xFFFFFFFF

    # Set DEBUG status if not already defined in the script.
    [[ "${DEBUG}" == "" ]] && DEBUG=0

    # Read arguments.
    IFS=/ read sub mask <<< "${1}"
    IFS=. read -a sub_ip <<< "${sub}"
    IFS=. read -a ip_a <<< "${2}"

    # Calculate netmask.
    netmask=$(($BITMASK<<$((32-$mask)) & $BITMASK))

    # Determine address range.
    start=0
    for o in "${sub_ip[@]}"
    do
        start=$(($start<<8 | $o))
    done

    start=$(($start & $netmask))
    end=$(($start | ~$netmask & $BITMASK))

    # Convert IP address to 32-bit number.
    ip=0
    for o in "${ip_a[@]}"
    do
        #echo $o &&
        ip=$(($ip<<8 | $o))
    done

    # Determine if IP in range.
    (( $ip >= $start )) && (( $ip <= $end )) && rval=1 || rval=0

    (( $DEBUG )) &&
        printf "ip=0x%08X; start=0x%08X; end=0x%08X; in_subnet=%u\n" $ip $start $end $rval 1>&2

    echo "${rval}"
}


# check if the client address belongs to a whitelisted subnet
allowed=0
for subnet in $allowed_subnets
do
    (( $(in_subnet $subnet $client_address) )) &&
        allowed=1 &&
        break
done 


# check if the client address is an whitelisted address
for address in $allowed_addresses
do
    if [ "$client_address" = "$address" ]
        then
            allowed=1 && 
            break
        fi
done


if [ "$allowed" = "1" ]
then 
    header="✅ALLOWED ACCESS✅"
else
    header="🚨UNAUTHORIZED ACCESS🚨"
fi

message="*${header}*

src: ${client_address}
dst: ${client_username}@${server_hostname}

${client_address} <==SSH==> ${server_address}

@ *${login_date} ${login_time}*"


if [ "$allowed" = "1" ] && [ "$only_unauthorized" = "0" ] || [ "$allowed" = "0" ]
then
    curl -s -d "chat_id=${chat_id}&text=${message}&disable_web_page_preview=true&parse_mode=markdown" $telegram_api_url > /dev/null
fi