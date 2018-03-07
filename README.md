# Tomcat letsencrypt renewal with Cron job

This script is to help you automate the process of renewing Letsencrypt ssl certficate on Tomcat server. There is a good tutorial for the initial setup of [Tomcat with Letsencrypt SSL certificate](https://computingforgeeks.com/tomcat-7-with-letsencrypt-ssl-certificate/) avilable on my blog.

For more details on prerequistes for this script, visit the page > [Bash Script to Auto-renew Letsencrypt SSL certificate on Tomcat](bash-script-to-auto-renew-letsencrypt-ssl-certificate-on-tomcat). It has all the details you need for both Debian based distributions and CentOS.

## Using the script

First clone the repository:

```
$ git clone https://github.com/jmutai/tomcat-letsencrypt.git
$ cd tomcat-letsencrypt
```

Once you have cloned the repo or downloaded the script. There are few variables that you need to define before you're ready to execute the script. These file to edit is `tomcat-letsencrypt-autorenew.sh`

```
TOMCAT_DOMAIN=""
TOMCAT_KEY_PASS=""
CERTBBOT_BIN="/usr/local/bin/certbot-auto"
EMAIL_NOTIFICATION="email_address"
```

Save the changes then:

```
$ chmod +x tomcat-letsencrypt-autorenew.sh
$ sudo cp tomcat-letsencrypt-autorenew.sh /usr/local/bin
```

The execute the script with:

```
$ sudo su -
# /usr/local/bin tomcat-letsencrypt-autorenew.sh
```

