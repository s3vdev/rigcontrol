# rigCONTROL v.1.0.O (March 2018) based on ethOS 1.3.x by Sven Mielke #
  
If you wish that you can control your ethOS Mining Rig than download rigstatuscontrol.sh and rigcontrol.sh to your folder /home/ethOS to manage your rig via Telegram Messenger.

See it in action: https://vimeo.com/260455169


![Showcase](https://i.imgur.com/GESZMmV.jpg)

### UPDATES ###
##

##
#### rigcontrol via Telegram Messenger - auto install ####

Simple download only install.sh to your folder /home/ethos and set chmod via:

``` chmod a+x /home/ethos/install.sh ```

Run install.sh via the following command:

``` bash install.sh ```

Install Video: https://vimeo.com/260577442

Finish :-)

##
#### rigcontrol via Telegram Messenger - manual install ####

Define a cronjob for rigstatuscontrol.sh, eg. every 5 minutes

``` sudo crontab -e ```

``` */5 * * * * /home/ethos/rigstatuscontrol.sh ```

Set chmod

``` chmod a+x /home/ethos/rigstatuscontrol.sh ```


Telegram commands:

``` /info <rigname> OR <workername> ```

``` /minestop <rigname> OR <workername> ```

``` /reboot <rigname> OR <workername> ```

``` /updateminers <rigname> OR <workername> ```

``` /restartproxy <rigname> OR <workername> ```

``` /apply_remote_changes <rigname> OR <workername> ```

``` /clearthermals <rigname> OR <workername> ```

``` /putconf <rigname> OR <workername> <URL> ```



Testing (try bash, calling sh make bash switch to posix mode and gives you some error)

To check if rigcontrol.sh is running, just type:
 
``` bash rigstatuscontrol.sh ``` 

To get a list of active screens, just type:

``` screen -ls ``` 

To resume to a screen, just type:

``` screen -r rigcontrol ```

Initialize a manually background process (after the first start, your cronjob will check if this process is running, if not than the process will restart automatically):

``` bash rigstatuscontrol.sh ``` 


##
#### Setup your vars in rigcheck.config ####

#### TELEGRAM ####
1. Open your Telegram App
2. GLOBAL SEARCH -> BotFather
3. Create a new bot by typing/clicking /newbot
4. Choose a user-friendly name for your bot, for example: awesomebot
5. Choose a unique username for your bot (must ends with â€œbotâ€)
6. copy your TOKEN e.g. 4334584910:AAEPmjlh84N62Lv3jGWEgOftlxxAfMhB1gs
7. Start a conversation with your bot: GLOBAL SEARCH -> MY_BOT_NAME -> START
8. Send "hello" to your bot. To get the chat ID, open the following URL in your web-browser: https://api.telegram.org/bot[TOKEN]/getUpdates
9. copy your chat id in var CHAT_ID and your token to TOKEN below

``` TOKEN="xyz" ```

``` CHAT_ID="yxz" ```


##
#### Pushover.net - Push notification gateway ####

Get push notifications to your iOS, Android or Windows Phone or Tablet.

Just register your free account and application and get all status message from ethOS to your Phone.

Please edit this new variables to activate push notification services: 

``` APP_TOKEN="xyz" ```

``` USER_KEY="yxz" ```


