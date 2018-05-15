# rigCONTROL v.1.0.O - Telegram Bot (March 2018) based on ethOS 1.3.x by Sven Mielke #
  
If you wish that you can control your ethOS Mining Rig than download rigstatuscontrol.sh and rigcontrol.sh to your folder /home/ethOS to manage your rig via Telegram Messenger.

See it in action: https://vimeo.com/260455169


![Showcase](https://i.imgur.com/RZU6VOG.jpg)

### UPDATES ###
##
2018-05-15 - Bugfixes with right chmod (set now automatically with 775)


##
### Install rigcontrol.sh to ethos ###

Setup via GIT
----
Clone the repository to your ethos home directory `/home/ethos`.
```bash
$ git clone https://s3v3n@bitbucket.org/s3v3n/rigcheck.git
```

Connect to you mining rig (via Filezilla SFTP or via SSH). 
User: ethos, Pass: live

Setup via Filezilla
----
1. Navigate to /home/ethos
2. Upload rigcontrol.sh AND rigstatuscontrol.sh AND rigcheck_config.sh to that directory
3. Change chmod to 755
4. Open your SSH terminal via Putty or any other ssh client
5. Type "sudo crontab -e"
6. Insert: "*/5 * * * * /home/ethos/rigstatuscontrol.sh"
7. Edit your vars in rigcheck_config.sh
8. Finished!

Setup via SSH
----
1. nano rigcontrol.sh
2. Copy & paste the complete script from rigcontrol.sh
3. CMD + X (mac) or STRG + X (Win) to save and close
4. Repeat this step with rigstatuscontrol.sh AND rigcheck_config.sh
5. Type: "chmod a+x rigcontrol.sh" and "chmod a+x rigstatuscontrol.sh" and "chmod a+x rigcheck_config.sh"
6. Create a cronjob: "sudo crontab -e"
7. Insert: */5 * * * * /home/ethos/rigstatuscontrol.sh
8. Edit your vars in rigcheck_config.sh
9. Finished!

#### via install.sh script: ####
1. Download install.sh to your /home/ethos folder
2. Type "chmod a+x install.sh"
3. Run "bash install.sh"
4. Answer the question
5. Finished!


#### rigcheck_config.sh (necessary only on manual install) ####
```
#### Notifications / Pushnotifications ####

#### TELEGRAM ####
1. Open your Telegram App
2. GLOBAL SEARCH -> BotFather
3. Create a new bot by typing/clicking /newbot
4. Choose a user-friendly name for your bot, for example: awesomebot
5. Choose a unique username for your bot (must ends with bot)
6. copy your TOKEN e.g. 43XXXXXX82:AAGRZjsXXXXXXXXXXlcPeyl1njlxIy60yg
7. Start a conversation with your bot: GLOBAL SEARCH -> MY_BOT_NAME -> START
8. To get the chat ID, open the following URL in your web-browser: https://api.telegram.org/bot[TOKEN]/getUpdates
9. copy your chat id in var CHAT_ID and your token to TOKEN below


#### Pushover.net - Push notification gateway ####
Get push notifications to your iOS, Android or Windows Phone or Tablet.
Just register your free account and application and get all status message from ethOS to your Phone.
Please edit this new variables to activate push notification services: 

RebootMaxRestarts="5";

MIN_HASHRATE_GPU="20";

MIN_TOTAL_HASH="90";

LOW_WATT="80";

TOKEN="43XXXXXX82:AAGRZjsXXXXXXXXXXlcPeyl1njlxIy60yg";

CHAT_ID="2XXXXXXX34";

APP_TOKEN="";

USER_KEY="";
```

##
#### Using ####

Telegram commands:

``` /info <rigname> OR <workername> ```

``` /minestop <rigname> OR <workername> ```

``` /reboot <rigname> OR <workername> ```

``` /updateminers <rigname> OR <workername> ```

``` /restartproxy <rigname> OR <workername> ```

``` /apply_remote_changes <rigname> OR <workername> ```

``` /clearthermals <rigname> OR <workername> ```

``` /putconf <rigname> OR <workername> <URL> ```


##
#### Testing ####
Testing (try bash, calling sh make bash switch to posix mode and gives you some error)

To check if rigcontrol.sh is running, just type:
 
``` bash rigstatuscontrol.sh ``` 

To get a list of active screens, just type:

``` screen -ls ``` 

To resume to a screen, just type:

``` screen -r rigcontrol ```

Initialize a manually background process (after the first start, your cronjob will check if this process is running, if not than the process will restart automatically):

``` bash rigstatuscontrol.sh ``` 

Enjoy!
