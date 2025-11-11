#!/bin/bash

# Simple Manual Payout Creator
# Prompts for all required information

set -e

echo "================================================"
echo "   TCGPlayer Manual Payout Creator"
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

# === STEP 2: Payout Details ===
echo ""
echo "STEP 2: Payout Details"
echo "----------------------"
read -p "Amount (e.g., 500.00): " AMOUNT
read -p "Currency (default: USD): " CURRENCY
CURRENCY=${CURRENCY:-USD}
echo ""

# === STEP 3: Recipient Bank Details ===
echo "STEP 3: Recipient Bank Information"
echo "-----------------------------------"
read -p "Account Holder Name: " ACCOUNT_HOLDER
read -p "Bank Account Number: " ACCOUNT_NUMBER
read -p "Bank Routing Number: " ROUTING_NUMBER
read -p "Bank Name: " BANK_NAME
echo ""

# === STEP 4: Additional Details ===
echo "STEP 4: Additional Details"
echo "--------------------------"
read -p "Payout Reason (e.g., weekly_settlement): " PAYOUT_REASON
read -p "Description: " DESCRIPTION
read -p "Scheduled Date (YYYY-MM-DD, press Enter for today): " SCHEDULED_DATE
SCHEDULED_DATE=${SCHEDULED_DATE:-$(date +%Y-%m-%d)}
read -p "Notify Recipient? (yes/no, default: yes): " NOTIFY
NOTIFY=${NOTIFY:-yes}
NOTIFY_BOOL=$([ "$NOTIFY" = "yes" ] && echo "true" || echo "false")
echo ""

# === Confirmation ===
echo "================================================"
echo "PAYOUT SUMMARY"
echo "================================================"
echo "Amount:           $CURRENCY $AMOUNT"
echo "Recipient:        $ACCOUNT_HOLDER"
echo "Bank:             $BANK_NAME"
echo "Account:          ***${ACCOUNT_NUMBER: -4}"
echo "Reason:           $PAYOUT_REASON"
echo "Scheduled:        $SCHEDULED_DATE"
echo "Notify Recipient: $NOTIFY"
echo "================================================"
read -p "Proceed with payout? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Payout cancelled"
    exit 0
fi

echo ""
echo "🔄 Processing payout..."
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

# === Create Payout ===
PAYOUT_RESPONSE=$(curl -s -X POST \
  "https://api.tcgplayer.com/v1.9.0/stores/${STORE_KEY}/payouts/manual" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
  "amount": '"${AMOUNT}"',
  "currency": "'"${CURRENCY}"'",
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
  "notifyRecipient": '"${NOTIFY_BOOL}"',
  "notes": "Manual payout created via console script"
}')

echo "✓ Payout created"
echo ""
echo "================================================"
echo "RESPONSE:"
echo "================================================"
echo "$PAYOUT_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$PAYOUT_RESPONSE"
echo ""

if echo "$PAYOUT_RESPONSE" | grep -q "payoutId\|results"; then
    echo "✅ SUCCESS: Manual payout created!"

    # Try to extract payout ID
    PAYOUT_ID=$(echo "$PAYOUT_RESPONSE" | grep -o '"payoutId":"[^"]*' | cut -d'"' -f4 | head -1)
    if [ ! -z "$PAYOUT_ID" ]; then
        echo "Payout ID: $PAYOUT_ID"
    fi
else
    echo "⚠️  Please check the response above"
fi
