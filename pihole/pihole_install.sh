# -----------------------------------------------------------------------------
# Install pihole
# -----------------------------------------------------------------------------

dietpi-software install 93

# -----------------------------------------------------------------------------
# Add lists
# -----------------------------------------------------------------------------

cat > /etc/pihole-updatelists.conf << EOF
ADLISTS_URL="https://raw.githubusercontent.com/kirstu/kirstu.github.io/master/pihole/lists/adlist.txt"
WHITELIST_URL="https://raw.githubusercontent.com/kirstu/kirstu.github.io/master/pihole/lists/whitelist.txt"
REGEX_WHITELIST_URL="https://raw.githubusercontent.com/kirstu/kirstu.github.io/master/pihole/lists/whitelist_regex.txt"
BLACKLIST_URL="https://raw.githubusercontent.com/kirstu/kirstu.github.io/master/pihole/lists/blacklist.txt"
REGEX_BLACKLIST_URL="https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list https://raw.githubusercontent.com/kirstu/kirstu.github.io/master/pihole/lists/blacklist_regex.txt https://raw.githubusercontent.com/MajkiIT/polish-ads-filter/master/polish-pihole-filters/hostfile_regex.txt"
EOF

# Clear out default lists
sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist;" && \
sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist_by_group;" && \
sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist;" && \
sqlite3 /etc/pihole/gravity.db "DELETE FROM domainlist_by_group;"

# Install pihole-updatelists cmd and update lists
wget -O - https://raw.githubusercontent.com/jacklul/pihole-updatelists/master/install.sh | sudo bash
pihole-updatelists

# Schedule list refresh for 4am every day
cat > /etc/cron.d/pihole-updatelists << EOF
0 4 * * *  root  /usr/local/sbin/pihole-updatelists
EOF
