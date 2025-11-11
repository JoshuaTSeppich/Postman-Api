#!/bin/bash

# Quick Manual Payout Example (with hardcoded test values)
# Replace the variables below with your actual credentials and data

# === CONFIGURATION - UPDATE THESE VALUES ===
PUBLIC_ID="your_public_id_here"
PRIVATE_ID="your_private_id_here"
STORE_KEY="your_store_key_here"

# Payout Details
AMOUNT=500.00
ACCOUNT_HOLDER="Store Owner Name"
ACCOUNT_NUMBER="123456789"
ROUTING_NUMBER="021000021"
BANK_NAME="Chase Bank"
PAYOUT_REASON="weekly_settlement"
DESCRIPTION="Manual payout for week ending $(date +%Y-%m-%d)"
SCHEDULED_DATE="2025-11-12"
# ==========================================

API_BASE_URL="https://api.tcgplayer.com"
API_VERSION="v1.9.0"

echo "Authenticating..."
AUTH_RESPONSE=$(curl -s -X POST "${API_BASE_URL}/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=${PUBLIC_ID}&client_secret=${PRIVATE_ID}")

ACCESS_TOKEN=$(echo $AUTH_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$ACCESS_TOKEN" ]; then
    echo "❌ Authentication failed!"
    echo "$AUTH_RESPONSE"
    exit 1
fi

echo "✓ Authenticated successfully"
echo ""
echo "Creating manual payout..."

curl -X POST \
  "${API_BASE_URL}/${API_VERSION}/stores/${STORE_KEY}/payouts/manual" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
  "amount": '"${AMOUNT}"',
  "currency": "USD",
  "destination": {
    "type": "bank_account",
    "accountNumber": "'"${ACCOUNT_NUMBER}"'",
    "routingNumber": "'"${ROUTING_NUMBER}"'",
    "accountHolderName": "'"${ACCOUNT_HOLDER}"'",
    "bankName": "'"${BANK_NAME}"'"
  },
  "payoutReason": "'"${PAYOUT_REASON}"'",
  "description": "'"${DESCRIPTION}"'",
  "metadata": {
    "processedBy": "console",
    "executedAt": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"
  },
  "scheduledDate": "'"${SCHEDULED_DATE}"'",
  "notifyRecipient": true,
  "notes": "Manual payout created via console"
}' | python3 -m json.tool

echo ""
echo "✓ Payout request completed"
