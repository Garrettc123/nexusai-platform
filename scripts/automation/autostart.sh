#!/data/data/com.termux/files/usr/bin/bash
# Place this in ~/.termux/boot/ to auto-start on device boot

sleep 30  # Wait for system to fully boot
cd ~/zero_touch_system
./launch_daemon.sh
