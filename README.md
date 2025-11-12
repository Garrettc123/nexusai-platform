# Prop Firm Challenge Bot with Auto-Reinvestment

A complete automated trading bot system designed specifically for **Termux** that automatically reinvests profits to compound your returns during prop firm challenges.

## 🎯 Key Features

### 💰 **Smart Compounding System**
- **Auto-reinvests 80% of profits** back into trading
- **Withdraws 20%** for risk management
- **Dynamic position sizing** that grows with your account
- **Exponential growth potential** for faster challenge completion

### 🛡️ **Advanced Risk Management**
- **Daily loss limits** (5% default, configurable)
- **Maximum drawdown protection** (10% default)
- **Position sizing based on stop loss distance**
- **Real-time balance monitoring**

### 📈 **Multiple Trading Strategies**
- **Momentum Strategy** - RSI-based oversold/overbought signals
- **Breakout Strategy** - Support/resistance breakout detection
- **Mean Reversion Strategy** - Bollinger Bands ranging markets

### 🔄 **Multi-Broker Support**
- **TradersPost** - Prop firm accounts (FTMO, TopStep, etc.)
- **Binance** - Cryptocurrency trading
- **OANDA** - Forex markets
- **Easy to extend** for additional brokers

## 📱 Installation on Termux

### Quick Install
```bash
# Clone or download all bot files
cd ~
mkdir prop-firm-bot
cd prop-firm-bot

# Make installer executable
chmod +x install_termux.sh

# Run automated installer
./install_termux.sh
```

### Manual Install
```bash
# Update Termux
pkg update -y && pkg upgrade -y

# Install required packages
pkg install python git wget nano -y

# Install Python dependencies
pip install -r requirements.txt

# Make scripts executable
chmod +x *.sh
```

## ⚙️ Configuration

Edit `config.json` with your specific parameters:

```json
{
  "api_key": "your_traderspost_api_key",
  "broker_type": "traderspost",
  "prop_firm": "ftmo",
  "initial_balance": 100000,
  "profit_target": 0.10,
  "max_daily_loss": 0.05,
  "reinvest_percentage": 0.80,
  "risk_per_trade": 0.01,
  "strategy": "momentum",
  "trade_enabled": false
}
```

### Prop Firm Settings

| Prop Firm | Profit Target | Daily Loss | Max Drawdown |
|-----------|---------------|------------|--------------|
| **FTMO** | 10% | 5% | 10% |
| **TopStep** | $3,000 | Varies | Varies |
| **FundedTrader** | 8% | 4% | 8% |
| **Earn2Trade** | 6% | 3% | 6% |
| **The5%ers** | 6% | 3% | 6% |

## 🚀 Running the Bot

### Start Paper Trading (Recommended First)
```bash
python prop_firm_bot.py
```

### Start Live Trading
```bash
# Enable live trading in config first
sed -i 's/"trade_enabled": false/"trade_enabled": true/' config.json

# Run in background
nohup python prop_firm_bot.py > logs/bot.log 2>&1 &

# Monitor logs
tail -f logs/bot.log
```

### Quick Start Script
```bash
./quick_start.sh
```

## 📊 How Auto-Reinvestment Works

### The Compounding Formula

```
New Balance = Current Balance + (Profit × 80%)
Position Size = (New Balance × Risk%) / (Entry - Stop Loss)
```

### Example Scenario:

1. **Start**: $100,000 account
2. **Trade 1 Win**: +$1,000 profit
3. **Auto-Distribute**:
   - $800 reinvested → New balance: $100,800
   - $200 withdrawn
4. **Trade 2**: Position size calculated on $100,800 (0.8% larger)
5. **Compound Effect**: Each win increases next trade's position size

### Growth Projection

| Week | Balance | Weekly Profit | Position Size Growth |
|------|---------|---------------|---------------------|
| 1 | $100,000 | $2,000 | Base |
| 4 | $106,500 | $2,130 | +6.5% |
| 8 | $113,800 | $2,276 | +13.8% |
| 12 | $121,500 | $2,430 | +21.5% |

## 📋 File Structure

```
prop-firm-bot/
├── prop_firm_bot.py      # Main bot engine (307 lines)
├── broker_api.py         # Broker integrations (195 lines)
├── strategies.py         # Trading strategies (182 lines)
├── config.json          # Configuration file
├── requirements.txt     # Python dependencies
├── install_termux.sh    # Automated installer
├── quick_start.sh       # Quick start menu
├── README.md           # This file
├── prop_bot.log        # Bot activity log
├── trade_log.json      # Trade history
└── logs/               # Additional log files
```

## 🛠️ Bot Features

### Core Capabilities
- ✅ **Real-time balance tracking**
- ✅ **Automatic profit reinvestment**
- ✅ **Daily loss limit enforcement**
- ✅ **Trade logging in JSON format**
- ✅ **Multiple strategy support**
- ✅ **Background operation**
- ✅ **24/7 trading capability**

### Strategy Details

#### Momentum Strategy
- Uses RSI indicators (14-period)
- Buys on oversold (<30)
- Sells on overbought (>70)
- Risk:Reward = 1:3

#### Breakout Strategy
- Support/resistance levels (20-day lookback)
- Trades breakouts above resistance
- Trades breakdowns below support
- Risk:Reward = 1:3

#### Mean Reversion Strategy
- Bollinger Bands (20, 2)
- Buys below lower band
- Sells above upper band
- Risk:Reward = 1:2

## ⚠️ Important Warnings

### Before Going Live

1. **TEST IN PAPER MODE FIRST**
   - Set `"trade_enabled": false`
   - Verify all signals work correctly
   - Monitor for 24-48 hours

2. **VERIFY PROP FIRM RULES**
   - Confirm automated trading is allowed
   - Check API trading permissions
   - Review risk management rules

3. **START SMALL**
   - Use minimum challenge size
   - Monitor first trades carefully
   - Have manual override ready

4. **RISK DISCLAIMER**
   - Trading involves significant risk
   - Past performance doesn't guarantee future results
   - Only trade capital you can afford to lose

### Common Issues

**API Connection Errors**
```bash
# Check API keys in config.json
# Verify broker permissions
# Test with curl: curl -H "Authorization: Bearer YOUR_KEY" https://api.broker.com
```

**Bot Stops Unexpectedly**
```bash
# Check logs: tail -50 prop_bot.log
# Ensure wake lock: termux-wake-lock
# Restart: ./quick_start.sh
```

**No Trading Signals**
```bash
# Check market hours in config
# Verify symbol availability
# Test strategy: python strategies.py
```

## 📈 Monitoring & Management

### Real-time Monitoring
```bash
# View live logs
tail -f prop_bot.log

# Check recent trades
tail -10 trade_log.json | jq .

# Monitor system resources
ps aux | grep python
```

### Performance Analytics
```bash
# View trade statistics
python -c "
import json
trades = [json.loads(line) for line in open('trade_log.json')]
wins = sum(1 for t in trades if t.get('pnl', 0) > 0)
print(f'Win Rate: {wins/len(trades)*100:.1f}%')
print(f'Total Trades: {len(trades)}')
"
```

### Backup & Restore
```bash
# Backup configuration
cp config.json config_backup.json

# Save trade history
cp trade_log.json trade_history_$(date +%Y%m%d).json
```

## 🔄 Running 24/7 on Termux

### Keep Bot Running Continuously
```bash
# Acquire wake lock (prevents sleep)
termux-wake-lock

# Start in background
nohup python prop_firm_bot.py > logs/bot.log 2>&1 &

# Check status
ps aux | grep prop_firm_bot

# View logs
tail -f logs/bot.log
```

### Auto-restart on Crash
```bash
# Create restart script
cat > restart_bot.sh << 'EOF'
#!/bin/bash
while true; do
    if ! pgrep -f "prop_firm_bot.py" > /dev/null; then
        echo "Bot not running, restarting..."
        cd ~/prop-firm-bot
        python prop_firm_bot.py
    fi
    sleep 60
done
EOF

chmod +x restart_bot.sh
nohup ./restart_bot.sh > logs/restart.log 2>&1 &
```

## 🤝 Support & Contributing

### Getting Help
1. Check this README first
2. Review log files for errors
3. Test with paper trading mode
4. Join our Discord community

### Contributing
- Fork the repository
- Create feature branch
- Submit pull request
- Share your strategies

## 📄 License & Disclaimer

**Educational Use Only** - This bot is for educational purposes. Trading involves substantial risk of loss. Always test thoroughly before risking real capital.

**Prop Firm Compliance** - Verify your prop firm's rules regarding automated trading before use.

**No Guarantee** - Past performance does not guarantee future results. Trade at your own risk.

---

## 🚀 Ready to Start?

1. **Install**: `./install_termux.sh`
2. **Configure**: Edit `config.json`
3. **Test**: Run in paper mode first
4. **Trade**: Enable live mode when ready
5. **Monitor**: Check logs and performance

**Happy Trading! 🎯💰**

*Built by traders, for traders. Running entirely on Android.*