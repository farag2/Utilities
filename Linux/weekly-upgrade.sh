#!/bin/bash
# Weekly full system upgrade with reboot.
# Install: /usr/local/sbin/weekly-upgrade.sh (chmod 755), run from root crontab.

# Upload file using Windows
# & "$env:SystemRoot\System32\OpenSSH\scp.exe" -P 6601 "D:\Downloads\weekly-upgrade.sh" sanctuary@208.115.251.106:~/

# Move file to /usr/local/sbin from Linux
# sed -i 's/\r$//' ~/weekly-upgrade.sh
# sudo install -m 755 ~/weekly-upgrade.sh /usr/local/sbin/weekly-upgrade.sh
# rm ~/weekly-upgrade.sh
# bash -n /usr/local/sbin/weekly-upgrade.sh && echo OK

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_SUSPEND=1

# Successful runs
LOG=/home/cron.log
# Failed runs: exit code and the command that failed
FAIL_LOG=/home/cron_fail.log
# Full apt output of the last run only (overwritten every week)
APT_LOG=/var/log/weekly-upgrade.last.log

# Wait up to 10 minutes if apt/dpkg is locked by another process
APT_OPTS=(-o DPkg::Lock::Timeout=600)
DPKG_OPTS=(-o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold)

# Run a command; on error log its exit code and stop the script (no reboot)
run()
{
    "$@" >> "$APT_LOG" 2>&1
    local rc=$?
    if [ "$rc" -ne 0 ]
    then
        echo "$(date): Failed $rc: $*" >> "$FAIL_LOG"
        exit "$rc"
    fi
}

# Xray geo databases used by 3x-ui; reboot below restarts Xray with the new files
GEO_DIR=/usr/local/x-ui/bin
LOYALSOLDIER=https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download
RUNETFREEDOM=https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/latest/download

# Download one geo file; on error log it and keep the old file (does not stop the script)
update_geo()
{
    local file="$GEO_DIR/$1"
    if curl -fsSL --retry 3 --max-time 300 -o "$file.new" "$2" >> "$APT_LOG" 2>&1 && [ -s "$file.new" ]
    then
        mv -f "$file.new" "$file"
    else
        rm -f "$file.new"
        echo "$(date): Failed: geo update $1" >> "$FAIL_LOG"
    fi
}

: > "$APT_LOG"

run apt-get "${APT_OPTS[@]}" update
run apt-get "${APT_OPTS[@]}" "${DPKG_OPTS[@]}" full-upgrade -y
run apt-get "${APT_OPTS[@]}" autoremove -y
run apt-get "${APT_OPTS[@]}" autoclean -y

update_geo geoip.dat     "$LOYALSOLDIER/geoip.dat"
update_geo geosite.dat   "$LOYALSOLDIER/geosite.dat"
update_geo geoip_RU.dat  "$RUNETFREEDOM/geoip.dat"
update_geo geosite_RU.dat "$RUNETFREEDOM/geosite.dat"

echo "$(date): Success" >> "$LOG"
systemctl reboot
rc=$?
if [ "$rc" -ne 0 ]
then
    echo "$(date): Failed $rc: reboot" >> "$FAIL_LOG"
fi
