#!/bin/bash

###################################################################################
#
# The MIT License
#
# Copyright 2018 Sven Mielke <web@ddl.bz>.
#
# Repository: https://bitbucket.org/s3v3n/rigcontrol - v1.0.0.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# rigcontrol based on ethOS 1.3.x
#
# Define a cronjob for the first run, for example every 5 minutes
#
# Set chmod
# chmod a+x /home/ethos/rigstatuscontrol.sh
#
# sudo crontab -e
# */5 * * * * /home/ethos/rigstatuscontrol.sh
#
# Edit your vars in rigcheck.config
#
#
# Telegram commands
# /info <rigname> OR <workername>
# /minestop <rigname> OR <workername>
# /reboot <rigname> OR <workername>
# /updateminers <rigname> OR <workername>
# /restartproxy <rigname> OR <workername>
# /apply_remote_changes <rigname> OR <workername>
# /clearthermals <rigname> OR <workername>
# /putconf <rigname> OR <workername> <URL>
#
# Finished!
#
# Testing (try bash, calling sh make bash switch to posix mode and gives you some error)
# To check if rigcontrol.sh is running, just type: bash test.php
# To get a list of active screens, just type: screen -ls
# To resume to a screen, just type: screen -r rigcontrol
#
#
# Donation
# You can send donations to any of the following addresses:
# BTC:  1Py8NMWNmtuZ5avyHFS977wZWrUWBMrfZH
# ETH:  0x8e9e03f6895320081b15141f2dc5fabc40317e8c
# BCH:  19sp8nSeDWN4FGrKSoGKdbeSgijGW8NBh9
# BTCP: ﻿b1CCUUdgSXFkg2c65WZ855HmgS4jsC54VRg
#
# ENJOY!
###################################################################################

# Coloring consolen output
RedEcho(){ echo -e "$(tput setaf 1)$1$(tput sgr0)"; }
GreenEcho(){ echo -e "$(tput setaf 2)$1$(tput sgr0)"; }
YellowEcho(){ echo -e "$(tput setaf 3)$1$(tput sgr0)"; }

# Include user config file
. /home/ethos/rigcheck_config.sh

# Check if vars on rigcheck_config.sh was set
if [[ -z "${MIN_TOTAL_HASH}" && -z "${LOW_WATT}" ]]
then
    RedEcho "Please setup your vars in /home/ethos/rigcheck_config.sh!";
    exit 1
fi

# Telegram API URL
telegramURL="https://api.telegram.org/bot$TOKEN/getUpdates";


status () {
   result="$(curl -s ${telegramURL} | python -c 'import sys, json; print json.load(sys.stdin)["'${1}'"]')" >> /dev/null;
   echo ${result}
}

msg () {
   result="$(curl -s ${telegramURL}${1} | python -c 'import sys, json; print json.load(sys.stdin)'${2}' ')" >> /dev/null;
   echo ${result}
}

notify () {
  if [[ -z "${TOKEN}" && -z "${APP_TOKEN}" ]];
  then
    echo "No push notifications configured"
  fi

  if [ -n "${TOKEN}" ];
  then
    echo "Sending telegram...";
    #Telegram notification
    curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d text="${1}" >> /dev/null
  fi

  if [ -n "${APP_TOKEN}" ];
  then
    echo "Sending pushover...";
    #Pushover notification
    curl -s --form-string "token=${APP_TOKEN}" \
            --form-string "user=${USER_KEY}" \
            --form-string "message=${1}" \
            https://api.pushover.net/1/messages.json >> /dev/null
  fi
}


# ##
# # stats.josn ethOS ver. 1.3.x
# StatsJson="/var/run/ethos/stats.json"
#
# ### EXIT IF STATS.JSON IS MISSING
# if [[ ! -f "$StatsJson" ]]; then
# 	echo "$(date "+%d.%m.%Y %T") EXIT: stats.json not available yet.(make sure ethosdistro is ver: 1.3.0+)"
# 	notify "ERROR: /var/run/ethos/stats.json not available yet.(make sure ethOS is ver: 1.3.0+. Run sudo ethos-update in your terminal.";
# 	exit 1
# fi
#
# stats () {
#    result="$(cat /var/run/ethos/stats.json | python -c 'import sys, json; print json.load(sys.stdin)["'${1}'"]')";
#    echo ${result}
# }


#{
#    "allowed": 1,
#    "pool_info": "proxywallet 0x5c29D34003eDD12B9D07b11d0332d627765dD4a7\npoolemail **@gmx.*\nproxypool1 eu2.ethermine.org:4444\nproxypool2 eu1.ethermine.org:4444",
#    "pool": "eu2.ethermine.org:4444",
#    "miner_version": "v11.5",
#    "rx_kbps": "4.64",
#    "tx_kbps": "1.04",
#    "kernel": "4.8.17-ethos49",
#    "boot_mode": "bios",
#    "uptime": "37266",
#    "mac": "2c4d54515d16",
#    "hostname": "515d16",
#    "rack_loc": "rig2",
#    "ip": "192.168.1.85",
#    "manu": "ASUSTeK",
#    "mobo": "H81M-PLUS",
#    "uuid": "8d8c1da5a3081869abe80ee0728a640a73467e40c56e15f6e8db89cc20862475",
#    "biosversion": "2205",
#    "lan_chip": "Realtek Semiconductor Co., Ltd. RTL8111\/8168\/8411 PCI Express Gigabit Ethernet Controller (rev 0c)",
#    "load": "0.23",
#    "ram": "4",
#    "cpu_temp": "32",
#    "cpu_name": "2 x Intel(R) Pentium(R) CPU G3260 @ 3.30GHz",
#    "rofs": 44,
#    "drive_name": "STORE N GO 0707279768443626",
#    "freespace": 1.6,
#    "temp": "71 62 65 52",
#    "version": "1.3.0",
#    "miner_secs": 37204,
#    "proxy_problem": "working",
#    "resolution": "1024 768",
#    "send_remote": "https:\/\/configmaker.com\/my\/*.txt",
#    "status": "98.8 hash: miner active",
#    "acceptance": "accepted",
#    "driver": "nvidia",
#    "gpus": "4",
#    "fanrpm": "3150 3150 3150 3150",
#    "fanpercent": "70 70 70 70",
#    "hash": "98.85",
#    "miner": "claymore",
#    "miner_hashes": "24.71 24.71 24.71 24.72",
#    "models": "01 GP106 GeForce GTX 1060 6GB 86.06.39.00.14\n02 GP106 GeForce GTX 1060 6GB 86.06.39.00.14\n03 GP106 GeForce GTX 1060 6GB 86.06.39.00.14\n05 GP106 GeForce GTX 1060 6GB 86.06.39.00.14",
#    "bioses": "86.06.39.00.14 86.06.39.00.14 86.06.39.00.14 86.06.39.00.14",
#    "default_core": "2025 2025 2025 2025",
#    "default_mem": "3802 3802 3802 3802",
#    "vramsize": "6 6 6 6",
#    "core": "1746 1771 1797 1809",
#    "mem": "4666 4666 4666 4666",
#    "memstates": "1 1 1 1",
#    "meminfo": "GPU0:01:00.0:GeForce GTX 1060 6GB:86.06.39.00.14:Unknown\nGPU1:02:00.0:GeForce GTX 1060 6GB:86.06.39.00.14:Unknown\nGPU2:03:00.0:GeForce GTX 1060 6GB:86.06.39.00.14:Unknown\nGPU3:05:00.0:GeForce GTX 1060 6GB:86.06.39.00.14:Unknown",
#    "voltage": "0.00 0.00 0.00 0.00",
#    "watts": "104 98 103 101",
#    "watt_min": "60 60 60 60",
#    "watt_max": "140 140 140 140",
#    "powertune": "2 2 2 2"
#}

##
# Possible interesting for bot "/info" comannd - based on stats.json
#
#    [MINING]
#    "pool": "eu2.ethermine.org:4444",
#    "proxy_problem": "working",
#    "miner": "claymore",
#    "miner_version": "v11.5",
#    "miner_secs": 37204,
#    "gpus": "4",
#    "fanrpm": "3150 3150 3150 3150",
#    "fanpercent": "70 70 70 70",
#    "hash": "98.85",
#    "miner_hashes": "24.71 24.71 24.71 24.72",
#    "rx_kbps": "4.64",
#    "tx_kbps": "1.04",

#    [GPU]
#    "driver": "nvidia",
#    "default_core": "2025 2025 2025 2025",
#    "default_mem": "3802 3802 3802 3802",
#    "vramsize": "6 6 6 6",
#    "core": "1746 1771 1797 1809",
#    "mem": "4666 4666 4666 4666",
#    "voltage": "0.00 0.00 0.00 0.00",
#    "watts": "104 98 103 101",
#    "watt_min": "60 60 60 60",
#    "watt_max": "140 140 140 140",
#    "powertune": "2 2 2 2"

#    [SYSTEM]
#    "manu": "ASUSTeK",
#    "mobo": "H81M-PLUS",
#    "biosversion": "2205",
#    "load": "0.23",
#    "ram": "4",
#    "cpu_temp": "32",
#    "version": "1.3.0",
#    "uptime": "37266",
#    "hostname": "515d16",
#    "rack_loc": "rig2",
#    "ip": "192.168.1.85",

#    [STORAGE]
#    "drive_name": "STORE N GO 0707279768443626",
#    "freespace": 1.6,

##
# NOW
#
# *Rig rig1-aba (487f84) info:*
# IP: 192.168.1.41
# Uptime: 19 hours, 15 minutes
# Miner: claymore (v11.0)
# Stratum: enabled
# GPU's: 6
# Driver: nvidia
# Hashrate: 187.02 hash
# Hash per GPU: 31.16 31.19 31.12 31.20 31.17 31.18
# Watts: 114 116 114 113 104 101
# FAN RPM: 3600 3600 3600 3600 3600 3600
# Statspanel: http://*.ethosdistro.com


timer () {
    while sleep 5; do apiWatch "$1"; done
}

apiWatch () {

    ##
    # Get update_id_next from timer function...
    if [ -n "$1" ];
    then
        update_id_next="$($1)";
    fi


    ##
    # Info: First get CURRENT update_id eg. => 521357970 on NEXT api call use => 521357971 on next => 521357972...
    # https://stackoverflow.com/questions/34296374/telegram-bot-api-limit-of-incoming-updates#34299503
    #
    if [ -z "${update_id_next}" ];
    then
        update_id="$( msg "?offset=100" '["result"][-1]["update_id"]' )";
    else
        update_id="$( msg "?offset=${update_id_next}" '["result"][-1]["update_id"]' )";
    fi


    ##
    # Get current local timestamp
    #timestamp=$(date +%s);

    ##
    # Get current local timestamp + 5 seconds
    timestamp_5=$(date --date='-7 seconds' +%s);

    ##
    # Waiting for next user input...
    GreenEcho "${update_id} - Waiting 5 seconds for next user input...";

    ##
    # Check if update_id is available
    if [ -n "${update_id}" ];
    then

        ##
        # Get telegram last message (array -1)
        msg="$( msg "?offset=${update_id}" '["result"][-1]["message"]["text"]' )";

        ##
        # Get telegram date
        telegram_date="$( msg "?offset=${update_id}" '["result"][-1]["message"]["date"]' )";

        ##
        # Check API Status
        if [ "$(status "ok")" = "True" ];
        then

            if [[ -n "${telegram_date}" && "${timestamp_5}" -lt "${telegram_date}" ]];
            then

                GreenEcho "Status: Ok ${msg}";

                ##
                # Get stats panel
                STATSPANEL="$(cat /var/run/ethos/url.file)";
                ##
                # Get Hostname
                RIGHOSTNAME="$(cat /etc/hostname)";
                ##
                # Get worker name for Pushover service
                worker="$(/opt/ethos/sbin/ethos-readconf worker)";
                ##
                # Get human uptime
                human_uptime="$(/opt/ethos/bin/human_uptime)";
                ##
                # Get current mining client,
                miner="$(/opt/ethos/sbin/ethos-readconf miner)";
                ##
                # Miner version
                miner_version="$(cat /var/run/ethos/miner.versions | grep ${miner} | cut -d" " -f2 | head -1)";
                ##
                # Stratum status
                stratum_check="$(/opt/ethos/sbin/ethos-readconf stratumenabled)";
                ##
                # Miner Hashes
                miner_hashes="$(tail -10 /var/run/ethos/miner_hashes.file | sort -V | tail -1)";
                ##
                # Get current total hashrate (as integer)
                hashRate="$(tail -10 /var/run/ethos/miner_hashes.file | sort -V | tail -1 | tr ' ' '\n' | awk '{sum +=$1} END {print sum}')";
                ##
                # Get all availible GPUs
                gpus="$(cat /var/run/ethos/gpucount.file)";
                ##
                # Get driver
                driver="$(/opt/ethos/sbin/ethos-readconf driver)";
                ##
                # Add watts check (best way to detect crash for Nvidia cards) (Thanks to Min Min)
                watts_raw="$(/opt/ethos/bin/stats | grep watts | cut -d' ' -f2- | sed -e 's/^[ \t]*//')";
                ##
                # Get current fan rpms
                fanrpm="$(/opt/ethos/sbin/ethos-readdata fanrpm | xargs | tr -s ' ')";
                ##
                # Get real local IP
                ip="$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)";


                ##
                # Split commands
                split_msg=$(echo $msg | awk -F" " '{print $1,$2,$3}');
                set -- $split_msg;


                ##
                # Check user command inputs...
                #

                ##
                # Get all infos about rig
                if [[ $1 = "/info" && $2 = "${worker}" || $1 = "/info" && $2 = "${RIGHOSTNAME}" ]]
                then
                   notify "*Rig ${worker} (${RIGHOSTNAME}) info:*"$'\n'"IP: ${ip}"$'\n'"Uptime: ${human_uptime}"$'\n'"Miner: ${miner} (${miner_version})"$'\n'"Stratum: ${stratum_check}"$'\n'"GPU's: ${gpus}"$'\n'"Driver: ${driver}"$'\n'"Hashrate: ${hashRate} hash"$'\n'"Hash per GPU: ${miner_hashes}"$'\n'"Watts: ${watts_raw}"$'\n'"FAN RPM: ${fanrpm}"$'\n'"Statspanel: ${STATSPANEL}";

                ##
                # Restart miner
                elif [[ $1 = "/minestop" && $2 = "${worker}" || $1 = "/minestop" && $2 = "${RIGHOSTNAME}" ]]
                then
                   /opt/ethos/bin/minestop
                   notify "Miner on Rig ${worker} (${RIGHOSTNAME}) has restarted now.";

                ##
                # Reboot rig
                elif [[ $1 = "/reboot" && $2 = "${worker}" || $1 = "/reboot" && $2 = "${RIGHOSTNAME}" ]]
                then
                   sudo /opt/ethos/bin/r
                   notify "Rig ${worker} (${RIGHOSTNAME}) is going down for reboot NOW!";

                ##
                # Update all miners on rig
                elif [[ $1 = "/updateminers" && $2 = "${worker}" || $1 = "/updateminers" && $2 = "${RIGHOSTNAME}" ]]
                then
                   notify "Rig ${worker} (${RIGHOSTNAME}) is updateing all miner programs to latest versions.";
                   sudo update-miners
                   notify "Rig ${worker} (${RIGHOSTNAME}) miner update completed.";

                ##
                # Restart proxy
                elif [[ $1 = "/restartproxy" && $2 = "${worker}" || $1 = "/restartproxy" && $2 = "${RIGHOSTNAME}" ]]
                then
                   restart-proxy
                   notify "Rig ${worker} (${RIGHOSTNAME}) local stratum proxy restarted.";

                ##
                # Apply remote changes
                elif [[ $1 = "/apply_remote_changes" && $2 = "${worker}" || $1 = "/apply_remote_changes" && $2 = "${RIGHOSTNAME}" ]]
                then
                   /opt/ethos/bin/putconf && /opt/ethos/bin/minestop && ethos-overclock
                   notify "Rig ${worker} (${RIGHOSTNAME}) remote and overclocking settings have been saved.";

                ##
                # Reset thermal-related throttling back to normal
                elif [[ $1 = "/clearthermals" && $2 = "${worker}" || $1 = "/clearthermals" && $2 = "${RIGHOSTNAME}" ]]
                then
                    /opt/ethos/bin/clear-thermals
                    notify "Rig ${worker} (${RIGHOSTNAME}) cleared all overheats and throttles and re-applied overclocks, set autoreboot counter back to 0.";

                ##
                # Insert new remote configuration to remote.conf file
                elif [[ $1 = "/putconf" && $2 = "${worker}" || $1 = "/putconf" && $2 = "${RIGHOSTNAME}" ]]
                then
                    echo $3 >> remote.conf
                    /opt/ethos/bin/putconf && /opt/ethos/bin/minestop && ethos-overclock
                    notify "Rig ${worker} (${RIGHOSTNAME}) new remote configuration $3 saved. Miner restarted successfully.";

                #else
                   # Nothing to do
                fi


                ##
                # Run timer function and exit here
                update_id_next=$(( $update_id + 1 ));
                timer "${update_id_next}";
                exit 1

            fi

        else
            RedEcho "Status: FAILED";

            if [[ -n "${worker}" && -n "${RIGHOSTNAME}" ]];
            then
               notify "API on Rig ${worker} (${RIGHOSTNAME}) FAILED!";
            fi
        fi

    else
       RedEcho "No update_id found! Post any text to your bot, to get a new update_id!";
    fi

    # Run timer function
    timer;
}

# First run...
apiWatch;