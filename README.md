# Service API Helper

This repository contains two files:
- `service_api_helper.postman_collection.json` - A Postman (https://www.getpostman.com) collection file that contains all API requests
- `service_api_helper.postman_environment` - Environment variables configuration

## Setup Instructions

1. **Import files into Postman**
   - Import both the collection and environment files

2. **Configure Store Credentials**

   The environment now supports **multiple stores with auto-fill functionality**:

   - `selectedStore` - Choose which store to use (store1, store2, or store3)
   - `store1_publicId` / `store1_privateId` - Credentials for Store 1
   - `store2_publicId` / `store2_privateId` - Credentials for Store 2
   - `store3_publicId` / `store3_privateId` - Credentials for Store 3

   **How Auto-Fill Works:**
   - Set your credentials for each store (store1_publicId, store1_privateId, etc.)
   - Change `selectedStore` to choose which store to use
   - When you run the **Authenticate** request, it automatically loads the correct credentials based on your selection

The rest of the fields will populate from scripts through the various requests. `storeAuthorizationCode` is part of the Store Authorization workflow present in the [main documentation](https://docs.tcgplayer.com/docs/store-authorization-workflow).

# Getting Started

After configuring your credentials in the environment:

## Authentication Workflow

### Option A: Store Authentication (Required for store-specific operations)

If your application needs to interact with store objects (orders, inventory, etc.):

1. Follow the [store authorization workflow](https://docs.tcgplayer.com/docs/store-authorization-workflow) to generate a store's authorization code
2. Enter this code into the `storeAuthorizationCode` environment variable
3. Run the **Store Authorization** request (the script automatically loads the authorization key)
4. Run the **Authenticate** request (credentials auto-fill based on your `selectedStore` selection)

After authentication, test by calling **Get Store Info** to verify your store information.

### Option B: Basic Authentication (No store access needed)

If you only need general API access:

1. Simply run the **Authenticate** request (credentials auto-fill based on your `selectedStore` selection)
2. You can now access non-store-specific endpoints in the collection

## Switching Between Stores

To switch stores, simply change the `selectedStore` environment variable to `store1`, `store2`, or `store3`, then re-run the **Authenticate** request. Your credentials will automatically update.

# Payment & Payout Endpoints

This collection now includes comprehensive payment and payout management endpoints:

## Accept Push Payment
**POST** `/v1.9.0/stores/{storeKey}/payments/push/accept`

Accept incoming push payments initiated by payers. Supports bank transfers and other push payment methods.

**Key Features:**
- Record payment source information (bank account, routing number)
- Link payments to orders and customers via metadata
- Timestamp payment acceptance
- Add custom notes for record-keeping

## Create Manual Payout
**POST** `/v1.9.0/stores/{storeKey}/payouts/manual`

Manually initiate payouts to store owners for settled transactions.

**Key Features:**
- Specify destination bank account details
- Schedule payouts for immediate or future processing
- Set payout reason (weekly_settlement, etc.)
- Include metadata for tracking (order count, processing period)
- Optional email notification to recipient

## List Store Payouts
**GET** `/v1.9.0/stores/{storeKey}/payouts`

Retrieve payout history with filtering options.

**Query Parameters:**
- `status`: pending, processing, completed, failed, cancelled
- `limit`: Number of results (default 50)
- `offset`: Pagination offset

## Get Payout Details
**GET** `/v1.9.0/stores/{storeKey}/payouts/{payoutId}`

Get detailed information about a specific payout including transaction details, fees, and processing timestamps.

## List Store Payments
**GET** `/v1.9.0/stores/{storeKey}/payments`

Retrieve payment history with filtering by payment method, date range, and status.

**Query Parameters:**
- `paymentMethod`: push, pull, card, bank_transfer
- `limit`: Number of results (default 50)
- `offset`: Pagination offset

## Cancel Manual Payout
**POST** `/v1.9.0/stores/{storeKey}/payouts/{payoutId}/cancel`

Cancel pending or scheduled payouts that haven't been processed yet. Requires cancellation reason.

---

# Notes

- This collection is currently configured for API version 1.9.0
- The environment supports up to 3 different stores with automatic credential switching
- All store-specific requests require proper authentication through the Store Authorization workflow

For questions and support, please refer to the [TCGPlayer community forums](https://community.tcgplayer.com).

---

**Original Repository:** Published by Joshua Burdick, Developer Evangelist at TCGPlayer.com
