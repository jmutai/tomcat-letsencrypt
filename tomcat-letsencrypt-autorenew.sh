#!/bin/bash
set -ex
DOMAIN=""
TOMCAT_KEY_PASS=""
CERTBOT_BIN="/usr/local/bin/certbot-auto"
EMAIL_NOTIFICATION="email_address"

# Install certbot

install_certbot () {
    if [[ ! -f /usr/local/bin/certbot-auto ]]; then
        wget https://dl.eff.org/certbot-auto -P /usr/local/bin
        chmod a+x $CERTBOT_BIN
    fi
}

# Attempt cert renewal:
renew_ssl () {
    ${CERTBOT_BIN} renew  > /tmp/crt.txt
    cat /tmp/crt.txt | grep "No renewals were attempted"
    if [[ $? -eq "0" ]]; then
        echo "Cert not yet due for renewal"
        exit 0
    else

    # Create Letsencypt ssl dir if doesn't exist
    echo "Renewing ssl certificate..."

    # create a PKCS12 that contains both your full chain and the private key
     rm -f /tmp/${DOMAIN}_fullchain_and_key.p12 2>/dev/null
     openssl pkcs12 -export -out /tmp/${DOMAIN}_fullchain_and_key.p12 \
       -passin pass:$TOMCAT_KEY_PASS \
       -passout pass:$TOMCAT_KEY_PASS \
       -in /etc/letsencrypt/live/$DOMAIN/fullchain.pem \
       -inkey /etc/letsencrypt/live/$DOMAIN/privkey.pem \
       -name tomcat
 fi
 }

      # Convert that PKCS12 to a JKS
    rm -f /etc/ssl/${DOMAIN}.jks 2>/dev/null
    keytool -importkeystore -deststorepass $TOMCAT_KEY_PASS -destkeypass $TOMCAT_KEY_PASS \
      -destkeystore /etc/ssl/${DOMAIN}.jks -srckeystore /tmp/${DOMAIN}_fullchain_and_key.p12  \
      -srcstoretype PKCS12 -srcstorepass $TOMCAT_KEY_PASS \
      -alias tomcat

# Send email notification on completion
send_email_notification () {
    if [[ $? -eq "0" ]]; then
        echo " Retarting tomcat server"
        systemctl restart tomcat
        if [[ $? -eq "0" ]]; then
            echo "" > /tmp/success
            echo "Letsencrypt ssl certificate for $DOMAIN successfully renewed by cron job." >> /tmp/success
            echo "" >> /tmp/success
            echo "Tomcat successfully restarted after renewal" >> /tmp/success
            mail -s "$DOMAIN Letsencrypt renewal" support-notify@angani.co < /tmp/success
        else
            echo "" > /tmp/failure
            echo "Letsencrypt ssl certificate for $DOMAIN renewal by cron job failed." >> /tmp/failure
            echo "" >> /tmp/failure
            echo "Try again manually.." >> /tmp/failure
            mail -s "$DOMAIN Letsencrypt renewal" $EMAIL_NOTIFICATION < /tmp/failure
        fi
    fi
}

# Main

install_certbot
renew_ssl
send_email_notification
