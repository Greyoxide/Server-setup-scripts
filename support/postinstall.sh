#!/bin/bash

# First we need to ask for a git dir to pull the app from
echo 'Input Git repo'
read repo

# Then we need to ask for a list of domain names
echo 'Input comma seperated list of domain names'
read domains

# We also need an email to register the cert
echo 'Input email to register certs with'
read email

# Next we should download the default nginx config file and insert the domain names

# Actions!
# first we should git pull the app and run the startup/config commands

# Then we should run certbot

certbot run -n --nginx --agree-tos -d example.com,www.example.com  -m  mygmailid@gmail.com  --redirect

# After that we should disallow ssh for the root user

#finally we should cleanup by deleting any downloaded scripts
