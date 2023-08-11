#!/bin/bash

redclr='\e[0;31m\033[1m'
endclr='\033[0m\e[0m'

#Functions
ping_scan(){
    rm ip.txt &>/dev/null
    local ps_subnet=$1
    for i in {1..255};do
        timeout 1 bash -c "ping -c 1 $ps_subnet.$i" &>/dev/null && echo -e "$ps_subnet.$i" >> ip.txt & 
        timeout 1 bash -c "ping -c 1 $ps_subnet.$i" &>/dev/null && echo -e "${redclr}[+]${endclr} Host: $ps_subnet.${redclr}$i${endclr} - Active" & 
    done; wait
}

decode_port_discovery(){
 echo "IyEvYmluL2Jhc2gKCnJlZGNscj0nXGVbMDszMW1cMDMzWzFtJwp5ZWxsb3djbHI9J1xlWzA7MzNtXDAzM1sxbScKZW5kY2xyPSdcMDMzWzBtXGVbMG0nCgpmdW5jdGlvbiBjdHJsX2MoKXsKICBlY2hvIC1lICdcblxuWyFdIEV4aXQuLi4nCiAgdHB1dCBjbm9ybTsgZXhpdCAxCn0KCnRyYXAgY3RybF9jIElOVAp0cHV0IGNpdmlzCgpkZWNsYXJlIC1hIGhvc3RzPSQoIGVjaG8gJDEgfCB0ciAnLScgJyAnKQoKZm9yIGhvc3QgaW4gJHtob3N0c1tAXX07ZG8gCiAgZWNobyAtZSAiSG9zdDogJGhvc3QiCiAgZm9yIHBvcnQgaW4gezEuLjEwMDAwfTtkbwogICAgdGltZW91dCAxIGJhc2ggLWMgImVjaG8gJycgPiAvZGV2L3RjcC8kaG9zdC8kcG9ydCIgMj4vZGV2L251bGwgJiYgZWNobyAtZSAiXHQke3llbGxvd2Nscn1bK10ke2VuZGNscn0gJHtyZWRjbHJ9JGhvc3Qke2VuZGNscn06JHtyZWRjbHJ9JHBvcnQke2VuZGNscn0gLSBPUEVOIiAKICBkb25lOyB3YWl0CmRvbmUKCnRwdXQgY25vcm0K" | base64 -d > pd.sh
}

port_scan(){
    host=$(cat ip.txt | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | tr '\n' '-')
    chmod +x pd.sh
    ./pd.sh $host
}

my_interfaces_and_ip(){
    #inter = interface
    nro_inter=$(ip a | awk '/inet /{print  $NF}' | wc -l)
    echo -e "\n\t${redclr}[!]${endclr} Number of ${redclr}Interfaces = $nro_inter${endclr}"
    inter_ip=$(ip a | awk -v red='\033[0;31m\033[1m' -v end_color='\033[0m\033[0m' '/inet /{print "\n[!] Interface -  "red $NF end_color" ""\n\tIP: "red $2 end_color}' | sed -E 's/\/([0-9]{1,3})//g')
    echo "$inter_ip"
}

#End Functions
#
subnet="$1"

if [ -z "$1" ]; then 
    echo -e "${redclr}\n\t[!]${endclr} Usage $0 <${redclr}10.10.10${endclr}>\n"
else
    my_interfaces_and_ip
    echo -e "\n\t${redclr}[!]${endclr} Range Subnet: ${redclr}$subnet${endclr}.0-254\n"
    ping_scan "$subnet"

    if [ -z "$2" ]; then #sin prmtro
        echo -e "${redclr}\n\t[!]${endclr} Usage $0 <${redclr}$subnet${endclr}> sport\n"
    else #con prmtro
        echo -e "\n\t${redclr}[!]${endclr} Port Scan: ${redclr}Top 10000 ${endclr}\n"
        decode_port_discovery
        port_scan 
    fi
fi
