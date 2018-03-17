#!/bin/bash

# Coloring consolen output
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
NC="$(tput sgr0)" # No Color

load () {
   result="$(curl -s https://api.bitbucket.org/2.0/repositories/s3v3n/rigcheck/commits | python -c 'import sys, json; print json.load(sys.stdin)["values"][0]["'${1}'"]')";
   echo ${result}
}

echo "";
echo "${GREEN}Do you wish to install rigcontrol to this ethOS mining rig?${NC}"
select yn in "Yes" "No"; do
    case $yn in
        Yes )

        ##
        # Setup LOW_WATT
        echo "Please enter your <LOW_WATT> e.g. 80 (80 Watts) for ethOS mining rig, followed by [ENTER]:"
        read low_watt

        echo "";
        echo "${GREEN}Would you like to config Telegram API to this ethOS mining rig?${NC}"
        select yn in "Yes" "No"; do
            case $yn in
                Yes )

                echo "";
                echo "How to get Telegram <CHAT_ID> and <TOKEN>?";
                echo "";
                echo "1. Open your Telegram App";
                echo "2. GLOBAL SEARCH -> BotFather";
                echo "3. Create a new bot by typing/clicking /newbot";
                echo "4. Choose a user-friendly name for your bot, for example: awesomebot";
                echo "5. Choose a unique username for your bot (must end with 'bot')";
                echo "6. copy your <TOKEN> e.g. 4334584910:AAEPmjlh84N62Lv3jGWEgOftlxxAfMhB1gs";
                echo "7. Start a conversation with your bot: GLOBAL SEARCH -> MY_BOT_NAME -> START";
                echo "8. To get the <CHAT_ID>, open the following URL in your web-browser: https://api.telegram.org/bot<TOKEN>/getUpdates";
                echo "9. copy your <CHAT_ID> e.g. 01234567";
                echo "";

                echo "Please enter your telegram CHAT_ID, followed by [ENTER]:"
                read chat_id

                echo "Please enter your Telegram TOKEN, followed by [ENTER]:"
                read token

                echo "";
                clear
                echo "${GREEN}[ OK ] Telegram config saved!${NC}";

                echo "";
                break;;
                No )break;;
            esac
        done



        echo "";
        echo "${GREEN}Would you like to config Pushover.net API to this ethOS mining rig?${NC}"
        select yn in "Yes" "No"; do
            case $yn in
                Yes )

                echo "";
                echo "How to get Pushover.net <APP_TOKEN> and <USER_KEY>?";
                echo "";
                echo "1. Register your free account on www.pushover.net.";
                echo "2. Create your free App";
                echo "3. Copy your <APP_TOKEN> and <USER_KEY>";
                echo "";

                echo "Please enter your Pushober APP_TOKEN, followed by [ENTER]:"
                read app_token

                echo "Please enter your Pushover USER_KEY, followed by [ENTER]:"
                read user_key

                echo "";
                clear
                echo "${GREEN}[ OK ] Pushover config saved!${NC}";



                echo "";
                break;;
                No )break;;
            esac
        done


        echo "${GREEN}Checking for new commit, please wait...${NC}";


        # Get hash from LAST commit
        hash="$(load hash)";
        lastCommit="$(load date)";
        modificationDate="$(date --date=$(stat -c%y rigcheck.sh | cut -c1-10) +"%s")";
        lastUpdate="$(date --date=$lastCommit +%s)";


        ##
        # Beginn downloading...
        if [ "${modificationDate}" \< "${lastUpdate}" ];
        then

            # Download and chmod files
            echo "Downloading rigcontrol.sh from bitbucket...";
            wget -N -q https://bitbucket.org/s3v3n/rigcheck/raw/${hash}/rigcontrol.sh -O /home/ethos/rigcontrol.sh

            sleep 0.3

            echo "Downloading rigstatuscontrol.sh from bitbucket...";
            wget -N -q https://bitbucket.org/s3v3n/rigcheck/raw/${hash}/rigstatuscontrol.sh -O /home/ethos/rigstatuscontrol.sh

            # Set chmod to new file
            echo "Setting up chmod 755 to rigcontrol.sh ...";
            chmod a+x /home/ethos/rigcontrol.sh

            sleep 0.3

            echo "Setting up chmod 755 to rigstatuscontrol.sh ...";
            chmod a+x /home/ethos/rigstatuscontrol.sh

            sleep 0.3

            # Creating cronjob...
            # sudo crontab -e
            # */5 * * * * /home/ethos/rigcontrol.sh
            # */5 * * * * /home/ethos/rigstatuscontrol.sh


            echo "All files successfully downloaded!";

            sleep 0.3

            echo "Creating rigcheck_config.sh file...";


cat <<EOT >> /home/ethos/rigcheck_config.sh
#!/bin/bash

###################################################################################
#
# The MIT License
#
# Copyright 2018 Sven Mielke <web@ddl.bz>.
#
# Repository: https://bitbucket.org/s3v3n/rigcheck.
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
#
# Telegram Notification (optional):
# Get status messages directly from your mining rigs if some errors occurred.
#
# 1. Open your Telegram App
# 2. GLOBAL SEARCH -> BotFather
# 3. Create a new bot by typing/clicking /newbot
# 4. Choose a user-friendly name for your bot, for example: awesomebot
# 5. Choose a unique username for your bot (must end with 'bot' )
# 6. copy your <TOKEN> e.g. 4334584910:AAEPmjlh84N62Lv3jGWEgOftlxxAfMhB1gs
# 7. Start a conversation with your bot: GLOBAL SEARCH -> MY_BOT_NAME -> START
# 8. To get the chat ID, open the following URL in your web-browser:
#    https://api.telegram.org/bot<TOKEN>/getUpdates
# 9. copy your chat id in var CHAT_ID and your token to TOKEN below
#
#
# Pushover.net Notification (optional):
# register your free account and get all status message to your Phone/Tablet.
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

### BEGINN EDIT ###

# If your hashrate is less than MIN_HASH, your miner will restart automatically
MIN_HASH="";


# IF your wattage is less than LOW_WATT, your miner will restart automatically
LOW_WATT="$low_watt";

# Telegram Gateway Service
TOKEN=""$token";
CHAT_ID=""$chat_id";


# Pushover.net Gateway Service
APP_TOKEN=""$app_token";
USER_KEY=""$user_key";

# Cron has diff env, some paths aren't found. adjust
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/ethos/bin:/opt/ethos/sbin

### END EDIT ###


# Check if some vars was set
if [[ -z ${MIN_HASH} && -z ${LOW_WATT}" && -z "${TOKEN} && -z ${CHAT_ID} ]]
then
    echo "Please setup your vars in /home/ethos/rigcheck_config.sh!";
    exit 1
fi
EOT



            sleep 0.3

            echo "Setting up chmod 755 to rigcheck_status.sh ...";
            chmod a+x /home/ethos/rigcheck_status.sh

            sleep 0.3

            echo "";
            echo "${GREEN}Installation of rigcontrol completed! Enjoy :-)${NC}";

        fi

        #echo "Telegram CHAT_ID is: $chat_id and your TOKEN is: $token";
        #echo "Pushover APP_TOKEN is: $app_token and your USER_KEY is: $user_key";
        #make install;

        echo "";
        break;;
        No ) exit;;
    esac
done