# Get Ip information
# https://github.com/vernette/ipregion
bash <(wget -qO- https://ipregion.vrnt.xyz)

# Censorship check
# https://github.com/vernette/censorcheck
bash <(wget -qO- https://github.com/vernette/censorcheck/raw/master/censorcheck.sh) --mode dpi
bash <(wget -qO- https://github.com/vernette/censorcheck/raw/master/censorcheck.sh) --mode geoblock

# Test connection to Russian iPerf servers
# https://github.com/itdoginfo/russian-iperf3-servers
bash <(wget -qO- https://github.com/itdoginfo/russian-iperf3-servers/raw/main/speedtest.sh)

# Yet-Another-Bench-Script
# https://github.com/masonr/yet-another-bench-script
curl -sL yabs.sh | -s -- -4

# Check VPS properties
# https://bench.sh
wget -qO- bench.sh | bash

# IP quality
# https://github.com/xykt/ScriptMenu
bash <(curl -Ls https://Check.Place) -EI

# CPU test
sysbench cpu run --threads=1

# Test server
https://github.com/saveksme/multitest/
