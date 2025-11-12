#!/usr/bin/env bash
# SOLANA AUTO-SWAP - COMPLETE SETUP + RUN
# Installs everything, then swaps SOL → USDC automatically

set -e

echo "════════════════════════════════════════════════════════"
echo "  SOLANA AUTO-SWAP INSTALLER + RUNNER"
echo "════════════════════════════════════════════════════════"
echo ""

# Fix nvm PREFIX issue
if [ -n "${PREFIX:-}" ]; then
    echo "[Fix] Unsetting PREFIX..."
    unset PREFIX
fi

# Step 1: Install dependencies
echo "[1/6] Installing dependencies..."
pkg update -y >/dev/null 2>&1
pkg install -y curl jq bc openssl >/dev/null 2>&1
echo "✓ Dependencies installed"

# Step 2: Install Solana CLI
if ! command -v solana &>/dev/null; then
    echo "[2/6] Installing Solana CLI (~2 minutes)..."
    sh -c "$(curl -sSfL https://release.solana.com/stable/install)" >/dev/null 2>&1
    export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
    echo "✓ Solana CLI installed"
else
    echo "[2/6] Solana CLI already installed"
    export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
fi

# Step 3: Create wallet
WALLET_PATH="$HOME/.config/solana/id.json"
if [ ! -f "$WALLET_PATH" ]; then
    echo "[3/6] Creating wallet..."
    mkdir -p "$HOME/.config/solana"
    "$HOME/.local/share/solana/install/active_release/bin/solana-keygen" new --no-passphrase --outfile "$WALLET_PATH" >/dev/null 2>&1
    echo "✓ Wallet created"
else
    echo "[3/6] Wallet exists"
fi

# Step 4: Configure network
echo "[4/6] Setting mainnet..."
"$HOME/.local/share/solana/install/active_release/bin/solana" config set --url https://api.mainnet-beta.solana.com >/dev/null 2>&1
echo "✓ Network configured"

# Step 5: Check wallet
PK=$("$HOME/.local/share/solana/install/active_release/bin/solana-keygen" pubkey "$WALLET_PATH")
BAL=$("$HOME/.local/share/solana/install/active_release/bin/solana" balance --url https://api.mainnet-beta.solana.com 2>/dev/null | awk '{print $1}' || echo "0")

echo "[5/6] Wallet info:"
echo "  Address: $PK"
echo "  Balance: $BAL SOL"

if (( $(echo "$BAL < 0.11" | bc -l) )); then
    echo ""
    echo "⚠️  WALLET NEEDS FUNDING ⚠️"
    echo ""
    echo "FREE (Devnet):"
    echo "  $HOME/.local/share/solana/install/active_release/bin/solana airdrop 2 --url https://api.devnet.solana.com"
    echo ""
    echo "Or transfer SOL to: $PK"
    echo ""
    echo "After funding, run: bash swap.sh"
    exit 0
fi

echo "✓ Wallet funded"
echo "[6/6] Starting swap..."
echo ""

# CONFIG
DEST="2ZFHJjTcE9d9o2jj77UheFNySHAYZSECq6fhbKfx252t"
AMT="0.1"
WSOL="So11111111111111111111111111111111111111112"
USDC="EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
API="https://quote-api.jup.ag/v6"
RPC="https://api.mainnet-beta.solana.com"
SOLANA="$HOME/.local/share/solana/install/active_release/bin/solana"
KP="$WALLET_PATH"

# Wrap SOL
echo "  [1/4] Wrapping $AMT SOL..."
$SOLANA transfer "$PK" "$AMT" --allow-unfunded-recipient --from "$KP" --url "$RPC" --skip-seed-phrase-validation >/dev/null 2>&1
$SOLANA token sync-native "$WSOL" --owner "$KP" --url "$RPC" >/dev/null 2>&1 || true
echo "  ✓ Wrapped"

# Get quote
echo "  [2/4] Getting quote..."
LAMPS=$(printf "%.0f" "$(echo "$AMT * 1000000000" | bc)")
curl -s "$API/quote?inputMint=$WSOL&outputMint=$USDC&amount=$LAMPS&slippageBps=100" -o /tmp/q.json
OUT=$(jq -r '.outAmount' /tmp/q.json)
echo "  ✓ Quote: $OUT USDC"

# Build swap
echo "  [3/4] Building swap..."
Q=$(cat /tmp/q.json)
curl -s -X POST -H 'Content-Type: application/json' -d "{"quoteResponse": $Q, "userPublicKey": "$PK", "prioritizationFeeLamports": "auto"}" "$API/swap" -o /tmp/s.json
echo "  ✓ Built"

# Send swap
echo "  [4/4] Sending..."
jq -r '.swapTransaction' /tmp/s.json | base64 --decode > /tmp/tx.bin
SIG=$($SOLANA send --url "$RPC" -k "$KP" /tmp/tx.bin 2>&1 | grep -oE '[A-Za-z0-9]{86,88}' | head -1)
echo "  ✓ Sent!"

rm -f /tmp/q.json /tmp/s.json /tmp/tx.bin

echo ""
echo "════════════════════════════════════════════════════════"
echo "  ✓ SWAP COMPLETE"
echo "════════════════════════════════════════════════════════"
echo ""
echo "Transaction: https://solscan.io/tx/$SIG"
echo "Your wallet: https://solscan.io/address/$PK"
echo ""
echo "Run 'bash swap.sh' again to swap more."
