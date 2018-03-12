#!/usr/bin/env bash
set -euo pipefail

LOG_PREFIX="============="
SERVER_LOCATION="/usr/share/nginx/html"

echo
echo "$LOG_PREFIX Updating sites"
echo

# update joshrosso.com
echo
echo "$LOG_PREFIX Updating joshrosso.com"
echo
cp -rv index.html $SERVER_LOCATION

# update octetz.com
echo
echo "$LOG_PREFIX Updating octetz.com"
echo
cp -rv ./octetz ${SERVER_LOCATION}/octetz-hugo

# update vanhabits.com
echo
echo "$LOG_PREFIX Updating vanhabits.com"
echo
cp -rv ./vanhabits ${SERVER_LOCATION}/vanhabits
