# Check telemt journal
sudo journalctl -u telemt -f

# Check telemt status
sudo telemt /etc/telemt/telemt.toml

# Telemt service
sudo systemctl start telemt
sudo systemctl restart telemt
sudo systemctl enable telemt
sudo systemctl status telemt
