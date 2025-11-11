#!/bin/bash

# TCGPlayer Manual Payout Execution Script
# This script authenticates and creates a manual payout

set -e

echo "======================================"
echo "TCGPlayer Manual Payout Creator"
echo "======================================"
echo ""

# Configuration
API_BASE_URL="https://api.tcgplayer.com"
API_VERSION="v1.9.0"

# Prompt for credentials if not set
read -p "Enter your Public ID (API Key): " PUBLIC_ID
read -sp "Enter your Private ID (Secret): " PRIVATE_ID
echo ""
read -p "Enter your Store Key: " STORE_KEY
echo ""

# Step 1: Authenticate
echo "Step 1: Authenticating..."
AUTH_RESPONSE=$(curl -s -X POST "${API_BASE_URL}/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=${PUBLIC_ID}&client_secret=${PRIVATE_ID}")

# Extract access token
ACCESS_TOKEN=$(echo $AUTH_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$ACCESS_TOKEN" ]; then
    echo "❌ Authentication failed!"
    echo "Response: $AUTH_RESPONSE"
    exit 1
fi

echo "✓ Authentication successful!"
echo "Access Token: ${ACCESS_TOKEN:0:20}..."
echo ""

# Step 2: Collect payout details
echo "Step 2: Enter payout details..."
read -p "Payout Amount (USD): " AMOUNT
read -p "Account Holder Name: " ACCOUNT_HOLDER
read -p "Bank Account Number: " ACCOUNT_NUMBER
read -p "Bank Routing Number: " ROUTING_NUMBER
read -p "Bank Name: " BANK_NAME
read -p "Payout Reason (e.g., weekly_settlement): " PAYOUT_REASON
read -p "Description: " DESCRIPTION
read -p "Scheduled Date (YYYY-MM-DD): " SCHEDULED_DATE
echo ""

# Step 3: Create Manual Payout
echo "Step 3: Creating manual payout..."

PAYOUT_PAYLOAD=$(cat <<EOF
{
  "amount": ${AMOUNT},
  "currency": "USD",
  "destination": {
    "type": "bank_account",
    "accountNumber": "${ACCOUNT_NUMBER}",
    "routingNumber": "${ROUTING_NUMBER}",
    "accountHolderName": "${ACCOUNT_HOLDER}",
    "bankName": "${BANK_NAME}"
  },
  "payoutReason": "${PAYOUT_REASON}",
  "description": "${DESCRIPTION}",
  "metadata": {
    "processedBy": "console",
    "executedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  },
  "scheduledDate": "${SCHEDULED_DATE}",
  "notifyRecipient": true,
  "notes": "Manual payout created via console"
}
EOF
)

echo "Sending payout request..."
PAYOUT_RESPONSE=$(curl -s -X POST \
  "${API_BASE_URL}/${API_VERSION}/stores/${STORE_KEY}/payouts/manual" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "${PAYOUT_PAYLOAD}")

echo ""
echo "======================================"
echo "PAYOUT RESPONSE:"
echo "======================================"
echo "$PAYOUT_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$PAYOUT_RESPONSE"
echo ""

# Check if successful
if echo "$PAYOUT_RESPONSE" | grep -q "payoutId\|results"; then
    echo "✓ Manual payout created successfully!"
else
    echo "⚠ Please check the response above for any errors"
fi
