#!/data/data/com.termux/files/usr/bin/bash
set -e

# Load environment
export $(cat .env | grep -v '^#' | xargs)

# Start Docker if needed
if ! pgrep dockerd > /dev/null; then
    dockerd --iptables=false &> /tmp/dockerd.log &
    sleep 3
fi

# Initialize Swarm
docker swarm init --advertise-addr 127.0.0.1 2>/dev/null || true

# Run orchestrator
python3 -m orchestrator.main "$@"