# Make it accessible being connected to a VPN server

# From Linux
echo '130.255.77.28 ntc.party www.ntc.party' | sudo tee -a /etc/hosts
curl -4 -sI https://ntc.party | head -1

# From Windows
Add-Content -Path "$env:SystemRoot\System32\drivers\etc\hosts" -Value "130.255.77.28 ntc.party www.ntc.party"
Clear-DnsClientCache
