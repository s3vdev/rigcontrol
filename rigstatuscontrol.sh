#!/bin/sh

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
# Finished!
#
# Testing (try bash, calling sh make bash switch to posix mode and gives you some error)
# To check if rigcontrol.sh is running, just type: bash rigstatuscontrol.sh
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

if ps -ef | grep -v grep | grep rigcontrol.sh  >> /dev/null;
then
        ##
        # Get the pids of rigcontrol
        pid="$(pgrep -f rigcontrol | xargs)";

        ##
        # Kill all rigcontrol pids
        # ps aux | grep -i rigcontrol | awk {'print $2'} | xargs kill -9

        GreenEcho "It's running under PID ${pid}";
        exit 0
else
        RedEcho "Rigcontrol was not running...";
        GreenEcho "Restarted.";
        screen -dmS rigcontrol bash /home/ethos/rigcontrol.sh 2>&1
        exit 0
fi