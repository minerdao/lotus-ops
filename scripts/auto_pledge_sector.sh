#########################################################################
# File Name: auto_pledge_sector.sh
# Created Time: Wed 25 Mar 2020 06:47:41 PM CST
#########################################################################
#!/bin/bash

lotus_path="/usr/local/bin"

# Colorefull print
function green_print()
{
    local text=$@

    echo ""
    echo -e "\033[1m\033[32m[$text]\033[0m"   # 绿色加粗, 并复原
    # echo ""
}
function blue_print()
{
    local text=$@

    # echo ""
    echo -e "\033[1m\033[36m[$text]\033[0m"   # 蓝色加粗, 并复原
    # echo ""
}
function blue_print2()
{
    local text=$@

    # echo ""
    echo -e "\033[36m[$text]\033[0m"   # 蓝色, 并复原
    # echo ""
}


green_print "Pledge sectors process starting..."
idx=1
pleNum=1
tm=3 # 15 min for each round
while ((idx<=2000))
do

    t=$(date +%Y_%m_%d_%H_%M)
    blue_print "[${t}]:"
    blue_print2 "[${idx}] pledge all sector!"
    for ((i=1; i<=pleNum; i++))
    do
     ${lotus_path}/lotus-miner sectors pledge
    done
    blue_print2 "Waitting ${tm} minutes..."
    
    echo -e ""
    let idx++
    #sleep 15m
    sleep ${tm}m

done
echo -e ""
