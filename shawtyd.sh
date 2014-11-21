#!/bin/bash
#################################################
#   shawtyd firewall
#       Blocks access to a port except for
#       whitelisted ip.
#
#       whitelisted ip is set through providing 
#       the codeword and an ip address to the 
#       fifo eg ("whitelist 127.0.0.1")
#
#       This must be run as root
#################################################
if [ "$(id -u)" -ne "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

### Config
target_ports="22 4200"
target_chain="SHAWTYD"
pipe=/tmp/shawtydfifo
codeword="whitelist"
### End Config
iptables_cmd="iptables"

destroy_rules() {
    for i in $target_ports; do
        $iptables_cmd -D INPUT -p tcp -m tcp --dport $i -j $target_chain;
    done
}

create_rules() {
    for i in $target_ports; do
        $iptables_cmd -I INPUT -p tcp -m tcp --dport $i -j $target_chain;
    done
}

flush_chain() {
    # Flush chain, it has the wrong number of rules
    $iptables_cmd -F $target_chain
    $iptables_cmd -A $target_chain -s $iparg -j ACCEPT
    $iptables_cmd -A $target_chain -j DROP
}

replace_whitelist() {
    # Assumes that rule 1 is our whitelist and rule 2 is DENY
    $iptables_cmd -I $target_chain -s $iparg -j ACCEPT
    # Insert a rule at top (#1) then delete the old top (#2)
    $iptables_cmd -D $target_chain 2
}

create_chain() {
    # Verify (create) chain for our firewall
    $iptables_cmd -N $target_chain
}

on_exit() {
    rm -f $pipe
    destroy_rules
    # flush firewall chain then delete it
    $iptables_cmd -F $target_chain
    $iptables_cmd -X $target_chain
}

update_whitelist() {
    if [[ $((`$iptables_cmd -L $target_chain | wc -l` - 2)) -eq 2 ]]; then
        replace_whitelist
    else
        flush_chain
    fi
}

create_pipe() {
    if [[ ! -p $pipe ]]; then
        mkfifo $pipe
    fi
    chmod 777 $pipe
}

trap "on_exit" EXIT

# Create fifo to recieve communication through
create_pipe

create_chain
# Refresh our rules
destroy_rules
create_rules

echo "shawtyd started successfully."
while true
do
    if read line <$pipe; then
        case $line in
            $codeword\ *)
                # strip the leading codeword from our ip
                iparg=${line##* }
                # get a rough estimate that iparg is ip like
                if [[ "$iparg" =~ ^([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})[.]([0-9]{1,3})$ ]]; then
                    update_whitelist
                    echo "Updated whitelisted ip to $iparg"
                else
                    echo "Warning: Invalid ip provided $iparg"
                fi
                ;;
            *)
                echo "Invalid command: $line"
                ;;
        esac
    fi
done
echo "shawtyd exiting."
