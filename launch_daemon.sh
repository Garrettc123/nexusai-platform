#!/data/data/com.termux/files/usr/bin/bash

cd ~/zero_touch_system
source venv/bin/activate

# Run as background daemon
nohup python autonomous_master.py > system_output.log 2>&1 &

echo "ðŸ¤– Zero-touch system launched as background daemon"
echo "PID: $!"
echo ""
echo "Commands:"
echo "  View logs: tail -f ~/zero_touch_system/autonomous_log.txt"
echo "  View output: tail -f ~/zero_touch_system/system_output.log"
echo "  Check status: ps aux | grep autonomous_master"
echo "  Stop system: pkill -f autonomous_master"
