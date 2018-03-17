#!/bin/bash

###################################################################################
#
# The MIT License
#
# Copyright 2018 Sven Mielke <web@ddl.bz>.
#
# Repository: https://bitbucket.org/s3v3n/rigcheck - v1.0.0.
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
# /apply-remote-changes <rigname> OR <workername>
# /clearthermals <rigname> OR <workername>
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

# Include user config file
. /home/ethos/rigcheck_config.sh

# Coloring consolen output
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
NC="$(tput sgr0)" # No Color

# Telegram API URL
telegramURL="https://api.telegram.org/bot$TOKEN/getUpdates";



status () {
   result="$(curl -s ${telegramURL} | python -c 'import sys, json; print json.load(sys.stdin)["'${1}'"]')" >> /dev/null;
   echo ${result}
}

msg () {
  # result="$(curl -s ${telegramURL}?offset=${1} | python -c 'import sys, json; print json.load(sys.stdin)["result"]['${2}']["'${3}'"]["'${4}'"]')";
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


timer () {
    while sleep 5; do apiWatch; done
}

apiWatch () {

    # Get current local timestamp
    #timestamp=$(date +%s);

    # Get current local timestamp + 5 seconds
    timestamp_5=$(date --date='-7 seconds' +%s);

   # update_id is limited 0 - 100 (so get always the last id - https://stackoverflow.com/questions/34296374/telegram-bot-api-limit-of-incoming-updates#34299503)
   # update_id="$( msg "100" "-1" "update_id" )";

    # Info: First get CURRENT update_id eg. => 521357970 on NEXT api call use => 521357971 on next => 521357972...
    if [ -z "${update_id_next}" ];
    then
        update_id="$( msg "?offset=100" '["result"][-1]["update_id"]' )";
    else
        update_id="$( msg "?offset=${update_id_next}" '["result"][-1]["update_id"]' )";
    fi

    #update_id_next=$(( $update_id + 1 ));
    #echo ${update_id} ${update_id_next};

    echo "${update_id} - ${GREEN}Waiting 5 seconds for next user input...${NC}";

    # Get update_id
    if [ -n "${update_id}" ];
    then

        # Get always the last message (array -1)
        #msg="$( msg "100" "-1" "message" "text" )";
        #msg="$( msg "?offset=${update_id_next}" '["result"][-1]["message"]["text"]' )";
        msg="$( msg "?offset=${update_id}" '["result"][-1]["message"]["text"]' )";

        # Get telegram date
        #telegram_date="$( msg "100" "-1" "message" "date" )";
        #telegram_date="$( msg "?offset=${update_id_next}" '["result"][-1]["message"]["date"]' )";
        telegram_date="$( msg "?offset=${update_id}" '["result"][-1]["message"]["date"]' )";


        # Check API Status
        if [ "$(status "ok")" = "True" ];
        then

            if [[ -n "${telegram_date}" && "${timestamp_5}" -lt "${telegram_date}" ]];
            then

                echo "Status: ${GREEN}Ok${NC} ${msg}";

                # Get Hostname
                RIGHOSTNAME="$(cat /etc/hostname)";
                # Get worker name for Pushover service
                worker="$(/opt/ethos/sbin/ethos-readconf worker)";
                # Get human uptime
                human_uptime="$(/opt/ethos/bin/human_uptime)";
                # Get current mining client,
                miner="$(/opt/ethos/sbin/ethos-readconf miner)";
                # Get current mining client,
                miner="$(/opt/ethos/sbin/ethos-readconf miner)";
                # Miner version
                miner_version="$(cat /var/run/ethos/miner.versions | grep ${miner} | cut -d" " -f2 | head -1)";
                # Stratum status
                stratum_check="$(/opt/ethos/sbin/ethos-readconf stratumenabled)";
                # Miner Hashes
                miner_hashes="$(tail -10 /var/run/ethos/miner_hashes.file | sort -V | tail -1)";
                # Get current total hashrate (as integer)
                hashRate="$(tail -10 /var/run/ethos/miner_hashes.file | sort -V | tail -1 | tr ' ' '\n' | awk '{sum +=$1} END {print sum}')";
                # Get all availible GPUs
                gpus="$(cat /var/run/ethos/gpucount.file)";
                # Get driver
                driver="$(/opt/ethos/sbin/ethos-readconf driver)";
                # Add watts check (best way to detect crash for Nvidia cards) (Thanks to Min Min)
                watts_raw="$(/opt/ethos/bin/stats | grep watts | cut -d' ' -f2- | sed -e 's/^[ \t]*//')";
                # Get stats panel
                STATSPANEL="$(cat /var/run/ethos/url.file)";
                # Get current fan speeds
                fanrpm="$(/opt/ethos/sbin/ethos-readdata fanrpm | xargs | tr -s ' ')";
                #Get real lokal IP
                ip="$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)";



                # Split commands
                split_msg=$(echo $msg | awk -F" " '{print $1,$2}');
                set -- $split_msg;
                # $1 eg. /uptime -- $2 eg. rig2;

                # Get all infos about rig
                if [[ $1 = "/info" && $2 = "${worker}" || $1 = "/info" && $2 = "${RIGHOSTNAME}" ]];
                then
                    notify "*Rig ${worker} (${RIGHOSTNAME}) info:*"$'\n'"IP: ${ip}"$'\n'"Uptime: ${human_uptime}"$'\n'"Miner: ${miner} (${miner_version})"$'\n'"Stratum: ${stratum_check}"$'\n'"GPU's: ${gpus}"$'\n'"Driver: ${driver}"$'\n'"Hashrate: ${hashRate} hash"$'\n'"Hash per GPU: ${miner_hashes}"$'\n'"Watts: ${watts_raw}"$'\n'"FAN RPM: ${fanrpm}"$'\n'"Statspanel: ${STATSPANEL}";
                    #exit 1
                fi

                # Restart miner
                if [[ $1 = "/minestop" && $2 = "${worker}" || $1 = "/minestop" && $2 = "${RIGHOSTNAME}" ]];
                then
                    /opt/ethos/bin/minestop
                    notify "Miner on Rig ${worker} (${RIGHOSTNAME}) has restarted now.";
                    #exit 1
                fi

                # Reboot rig
                if [[ $1 = "/reboot" && $2 = "${worker}" || $1 = "/reboot" && $2 = "${RIGHOSTNAME}" ]];
                then
                    sudo /opt/ethos/bin/r
                    notify "Rig ${worker} (${RIGHOSTNAME}) is going down for reboot NOW!";
                    #exit 1
                fi

                # Update all miners on rig
                if [[ $1 = "/updateminers" && $2 = "${worker}" || $1 = "/updateminers" && $2 = "${RIGHOSTNAME}" ]];
                then
                    notify "Rig ${worker} (${RIGHOSTNAME}) is updateing all miner programs to latest versions.";
                    sudo update-miners
                    notify "Rig ${worker} (${RIGHOSTNAME}) miner update completed.";
                    #exit 1
                fi

                # Restart proxy
                if [[ $1 = "/restartproxy" && $2 = "${worker}" || $1 = "/restartproxy" && $2 = "${RIGHOSTNAME}" ]];
                then
                    restart-proxy
                    notify "Rig ${worker} (${RIGHOSTNAME}) local stratum proxy restarted.";
                    #exit 1
                fi

                # Apple remote changes
                if [[ $1 = "/apply-remote-changes" && $2 = "${worker}" || $1 = "/apply-remote-changes" && $2 = "${RIGHOSTNAME}" ]];
                then
                    /opt/ethos/bin/putconf && /opt/ethos/bin/minestop && ethos-overclock
                    notify "Rig ${worker} (${RIGHOSTNAME}) remote and overclocking settings have been saved.";
                    #exit 1
                fi

                # Reset thermal-related throttling back to normal
                if [[ $1 = "/clearthermals" && $2 = "${worker}" || $1 = "/clearthermals" && $2 = "${RIGHOSTNAME}" ]];
                then
                    /opt/ethos/bin/clear-thermals
                    notify "Rig ${worker} (${RIGHOSTNAME}) cleared all overheats and throttles and re-applied overclocks, set autoreboot counter back to 0.";
                    #exit 1
                fi
            fi

        else
            echo "Status: ${RED}FAILED${NC}";

            if [[ -n "${worker}" && -n "${RIGHOSTNAME}" ]];
            then
               notify "API on Rig ${worker} (${RIGHOSTNAME}) FAILED!";
               #exit 1
            fi
        fi

    else
       echo "${RED}No update_id found! Post any text to your bot, to get a new update_id!${NC}";
    fi

    # Run timer function
    timer
}

# First run...
apiWatch
