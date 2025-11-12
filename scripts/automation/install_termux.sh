#!/bin/bash
# Prop Firm Bot Installer for Termux
# Automated setup script for Android trading bot

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   ██████╗ ███████╗███╗   ██╗███████╗███████╗██╗███████╗     ║
║  ██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔════╝██║██╔════╝     ║
║  ██║  ███╗█████╗  ██╔██╗ ██║█████╗  ███████╗██║███████╗     ║
║  ██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ╚════██║██║╚════██║     ║
║  ╚██████╔╝███████╗██║ ╚████║███████╗███████║██║███████║     ║
║   ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚══════╝     ║
║                                                               ║
║           Prop Firm Challenge Bot v1.0                       ║
║              Auto-Reinvestment System                        ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${GREEN}🚀 Starting Prop Firm Bot Installation...${NC}"

# Update Termux packages
echo -e "${YELLOW}[1/6]${NC} Updating Termux packages..."
pkg update -y && pkg upgrade -y

# Install required packages
echo -e "${YELLOW}[2/6]${NC} Installing Python and dependencies..."
pkg install python git wget curl nano -y

# Install Python packages
echo -e "${YELLOW}[3/6]${NC} Installing Python libraries..."
pip install --upgrade pip
pip install -r requirements.txt

# Create bot directory
echo -e "${YELLOW}[4/6]${NC} Setting up bot directory..."
mkdir -p ~/prop-firm-bot
cd ~/prop-firm-bot

# Make scripts executable
echo -e "${YELLOW}[5/6]${NC} Configuring permissions..."
chmod +x *.sh

# Create log directory
mkdir -p logs

echo -e "${GREEN}✅ Installation completed successfully!${NC}"

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                    NEXT STEPS                                ║
╚═══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${GREEN}1. Configure your settings:${NC}"
echo -e "${BLUE}   nano config.json${NC}"
echo -e "   Add your API keys and trading parameters"

echo ""
echo -e "${GREEN}2. Test the bot in paper trading mode:${NC}"
echo -e "${BLUE}   python prop_firm_bot.py${NC}"

echo ""
echo -e "${GREEN}3. Run 24/7 (optional):${NC}"
echo -e "${BLUE}   termux-wake-lock${NC}"
echo -e "${BLUE}   nohup python prop_firm_bot.py > logs/bot.log 2>&1 &${NC}"

echo ""
echo -e "${GREEN}4. Monitor your bot:${NC}"
echo -e "${BLUE}   tail -f logs/bot.log${NC}"
echo -e "${BLUE}   cat trade_log.json | jq .${NC}"

echo ""
echo -e "${YELLOW}⚠️  IMPORTANT:${NC}"
echo -e "   • Start with paper trading mode"
echo -e "   • Verify prop firm allows automated trading"
echo -e "   • Monitor first 48 hours closely"
echo -e "   • Only enable live trading after testing"

echo ""
echo -e "${GREEN}📊 Bot Features:${NC}"
echo -e "   • Auto-reinvestment (80% profits compounded)"
echo -e "   • Daily loss limits (5% default)"
echo -e "   • Multiple trading strategies"
echo -e "   • Real-time balance tracking"
echo -e "   • Comprehensive trade logging"

echo ""
echo -e "${GREEN}✨ Happy Trading!${NC}"