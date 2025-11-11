#!/bin/bash

# Manual Crypto Payout Creator with HIGH PRIORITY GAS
# Ensures near-immediate transfer with extra gas settings

set -e

echo "================================================"
echo "   Manual Crypto Payout Creator"
echo "   HIGH PRIORITY - Near-Immediate Transfer"
echo "================================================"
echo ""

# === STEP 1: API Credentials ===
echo "STEP 1: API Credentials"
echo "------------------------"
read -p "Public ID (API Key): " PUBLIC_ID
read -sp "Private ID (Secret): " PRIVATE_ID
echo ""
read -p "Store Key: " STORE_KEY
echo ""

# === STEP 2: Cryptocurrency Selection ===
echo ""
echo "STEP 2: Select Cryptocurrency"
echo "-----------------------------"
echo "1) Bitcoin (BTC) - 150+ sat/vB (next block)"
echo "2) Ethereum (ETH) - 150 Gwei + 10 Gwei priority"
echo "3) USDC (Ethereum) - 150 Gwei + 10 Gwei priority"
echo "4) USDT (Tron TRC-20) - 100k energy (3-second blocks)"
read -p "Select cryptocurrency [1-4]: " CRYPTO_CHOICE
echo ""

# === STEP 3: Payout Details ===
echo "STEP 3: Payout Details"
echo "----------------------"

case $CRYPTO_CHOICE in
    1)
        CURRENCY="BTC"
        NETWORK="bitcoin"
        read -p "Amount (BTC, e.g., 0.015): " AMOUNT
        read -p "Bitcoin Address (bc1... or legacy): " CRYPTO_ADDRESS
        ADDRESS_TYPE="bech32"
        ;;
    2)
        CURRENCY="ETH"
        NETWORK="ethereum"
        read -p "Amount (ETH, e.g., 0.5): " AMOUNT
        read -p "Ethereum Address (0x...): " CRYPTO_ADDRESS
        ;;
    3)
        CURRENCY="USDC"
        NETWORK="ethereum"
        read -p "Amount (USDC, e.g., 1500.00): " AMOUNT
        read -p "Ethereum Address (0x...): " CRYPTO_ADDRESS
        CONTRACT_ADDRESS="0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
        ;;
    4)
        CURRENCY="USDT"
        NETWORK="tron"
        read -p "Amount (USDT, e.g., 1500.00): " AMOUNT
        read -p "Tron Address (T...): " CRYPTO_ADDRESS
        CONTRACT_ADDRESS="TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t"
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

read -p "Description: " DESCRIPTION
read -p "Notify Recipient? (yes/no, default: yes): " NOTIFY
NOTIFY=${NOTIFY:-yes}
NOTIFY_BOOL=$([ "$NOTIFY" = "yes" ] && echo "true" || echo "false")
echo ""

# === Build Request Body ===
if [ "$CURRENCY" = "BTC" ]; then
    REQUEST_BODY='{
  "amount": '"${AMOUNT}"',
  "currency": "BTC",
  "destination": {
    "type": "crypto_address",
    "address": "'"${CRYPTO_ADDRESS}"'",
    "network": "bitcoin",
    "addressType": "bech32",
    "memo": ""
  },
  "payoutReason": "manual_crypto_settlement",
  "description": "'"${DESCRIPTION}"'",
  "metadata": {
    "processedBy": "console",
    "executedAt": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'",
    "manualPayout": true
  },
  "priority": "high",
  "feeSettings": {
    "feeRate": "150",
    "rbfEnabled": true
  },
  "notifyRecipient": '"${NOTIFY_BOOL}"',
  "notes": "Manual Bitcoin payout - HIGH PRIORITY with extra gas for near-immediate transfer (next block)"
}'
elif [ "$CURRENCY" = "ETH" ]; then
    REQUEST_BODY='{
  "amount": '"${AMOUNT}"',
  "currency": "ETH",
  "destination": {
    "type": "crypto_address",
    "address": "'"${CRYPTO_ADDRESS}"'",
    "network": "ethereum",
    "chainId": 1
  },
  "payoutReason": "manual_crypto_settlement",
  "description": "'"${DESCRIPTION}"'",
  "metadata": {
    "processedBy": "console",
    "executedAt": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'",
    "manualPayout": true
  },
  "gasSettings": {
    "priority": "high",
    "maxFeePerGas": "150",
    "maxPriorityFeePerGas": "10",
    "gasLimit": "21000"
  },
  "notifyRecipient": '"${NOTIFY_BOOL}"',
  "notes": "Manual Ethereum payout - HIGH PRIORITY with extra gas (150 Gwei + 10 Gwei priority) for near-immediate transfer"
}'
elif [ "$CURRENCY" = "USDC" ]; then
    REQUEST_BODY='{
  "amount": '"${AMOUNT}"',
  "currency": "USDC",
  "destination": {
    "type": "crypto_address",
    "address": "'"${CRYPTO_ADDRESS}"'",
    "network": "ethereum",
    "chainId": 1,
    "contractAddress": "'"${CONTRACT_ADDRESS}"'"
  },
  "payoutReason": "manual_crypto_settlement",
  "description": "'"${DESCRIPTION}"'",
  "metadata": {
    "processedBy": "console",
    "executedAt": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'",
    "tokenStandard": "ERC-20",
    "manualPayout": true
  },
  "gasSettings": {
    "priority": "high",
    "maxFeePerGas": "150",
    "maxPriorityFeePerGas": "10",
    "gasLimit": "65000"
  },
  "notifyRecipient": '"${NOTIFY_BOOL}"',
  "notes": "Manual USDC payout - HIGH PRIORITY with extra gas for near-immediate transfer"
}'
elif [ "$CURRENCY" = "USDT" ]; then
    REQUEST_BODY='{
  "amount": '"${AMOUNT}"',
  "currency": "USDT",
  "destination": {
    "type": "crypto_address",
    "address": "'"${CRYPTO_ADDRESS}"'",
    "network": "tron",
    "tokenStandard": "TRC-20",
    "contractAddress": "'"${CONTRACT_ADDRESS}"'"
  },
  "payoutReason": "manual_crypto_settlement",
  "description": "'"${DESCRIPTION}"'",
  "metadata": {
    "processedBy": "console",
    "executedAt": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'",
    "networkBenefit": "Fast confirmation with premium energy",
    "manualPayout": true
  },
  "energySettings": {
    "energyLimit": 100000,
    "feelimit": 200000000,
    "priority": "high"
  },
  "notifyRecipient": '"${NOTIFY_BOOL}"',
  "notes": "Manual USDT Tron payout - HIGH PRIORITY with extra energy for near-immediate transfer (3-second blocks)"
}'
fi

# === Confirmation ===
echo "================================================"
echo "CRYPTO PAYOUT SUMMARY (HIGH PRIORITY)"
echo "================================================"
echo "Currency:         $CURRENCY"
echo "Amount:           $AMOUNT"
echo "Network:          $NETWORK"
echo "Address:          ${CRYPTO_ADDRESS:0:20}..."
echo "Priority:         HIGH (Near-Immediate Transfer)"

case $CURRENCY in
    BTC) echo "Fee Rate:         150+ sat/vB (next block target)" ;;
    ETH) echo "Gas Settings:     150 Gwei base + 10 Gwei priority" ;;
    USDC) echo "Gas Settings:     150 Gwei + 65k limit (ERC-20)" ;;
    USDT) echo "Energy:           100k energy + 200 TRX fee limit" ;;
esac

echo "Notify Recipient: $NOTIFY"
echo "================================================"
read -p "Proceed with HIGH PRIORITY payout? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Payout cancelled"
    exit 0
fi

echo ""
echo "🔄 Processing HIGH PRIORITY crypto payout..."
echo ""

# === Authentication ===
AUTH_RESPONSE=$(curl -s -X POST "https://api.tcgplayer.com/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=${PUBLIC_ID}&client_secret=${PRIVATE_ID}")

ACCESS_TOKEN=$(echo $AUTH_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$ACCESS_TOKEN" ]; then
    echo "❌ Authentication failed!"
    echo "Response: $AUTH_RESPONSE"
    exit 1
fi

echo "✓ Authenticated"

# === Create Crypto Payout ===
PAYOUT_RESPONSE=$(curl -s -X POST \
  "https://api.tcgplayer.com/v1.9.0/stores/${STORE_KEY}/payouts/crypto" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$REQUEST_BODY")

echo "✓ Crypto payout submitted"
echo ""
echo "================================================"
echo "RESPONSE:"
echo "================================================"
echo "$PAYOUT_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$PAYOUT_RESPONSE"
echo ""

if echo "$PAYOUT_RESPONSE" | grep -q "payoutId\|txHash\|results"; then
    echo "✅ SUCCESS: HIGH PRIORITY crypto payout created!"

    # Try to extract details
    PAYOUT_ID=$(echo "$PAYOUT_RESPONSE" | grep -o '"payoutId":"[^"]*' | cut -d'"' -f4 | head -1)
    TX_HASH=$(echo "$PAYOUT_RESPONSE" | grep -o '"txHash":"[^"]*' | cut -d'"' -f4 | head -1)

    if [ ! -z "$PAYOUT_ID" ]; then
        echo "Payout ID: $PAYOUT_ID"
    fi
    if [ ! -z "$TX_HASH" ]; then
        echo "Transaction Hash: $TX_HASH"
        echo ""
        case $CURRENCY in
            BTC) echo "🔍 Track on: https://mempool.space/tx/$TX_HASH" ;;
            ETH) echo "🔍 Track on: https://etherscan.io/tx/$TX_HASH" ;;
            USDC) echo "🔍 Track on: https://etherscan.io/tx/$TX_HASH" ;;
            USDT) echo "🔍 Track on: https://tronscan.org/#/transaction/$TX_HASH" ;;
        esac
    fi

    echo ""
    echo "⚡ HIGH PRIORITY settings enabled for near-immediate transfer!"
else
    echo "⚠️  Please check the response above"
fi
