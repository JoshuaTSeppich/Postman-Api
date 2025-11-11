# Postman-Api
This repository contains two files.  The first, TCGPlayer.postman_collection.json, is a Postman (https://www.getpostman.com) collection file that contains all of the current API requests.  The second file, TCGPlayer.postman_environment, contains a set of environment variables that will need to be set and configured to get the collection to work.

First you will need to import both of these files into Postman.  After that is done, modify the environment variables to match your credentials.  The ones that need to be modified are:
publicId- this is the public key that you were given when receiving API access
privateId- this is the private key that you were given when receiving API access

The rest of the fields will populate from scripts through the various requests.  storeAuthorizationCode is part of the Store Authorization workflow present in the [main documentation](https://docs.tcgplayer.com/docs/store-authorization-workflow).

# Getting started with TCGPlayer Postman requests
After your keys are entered into the imported environment, there are two paths to follow depending on if you want to authenticate against a store.  This is only necessary if your application will be interacting with store objects, such as by pulling a store's orders.

If you don't want to authenticate against a store, skip to step 4.

### 1)
Follow the [store authorization workflow](https://docs.tcgplayer.com/docs/store-authorization-workflow) until you have generated a store's authorization code.
### 2)
Enter this code into your Postman environment under the storeAuthorizationCode variable.
### 3)
Run the request for Store Authorization.  You don't need to copy anything from the response, the script handles it and loads the appropriate environment variables.
### 4)
Run the request for Authenticate.

After this is completed, you should be able to start diving in and running any of the other requests in the collection.  If you authenticated against a store, a great next step is to call Get Store Info so that you can verify that your store's information is returned correctly.

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

# Google Cloud Organization Policy

This repository includes configuration and scripts for deploying a custom Google Cloud Organization Policy that restricts Compute Engine VM creation to only N2D machine types.

## What's Included

The `gcp-org-policy/` directory contains:

- **YAML Configuration**: Custom constraint definition for N2D-only enforcement
- **Bash Script**: Automated deployment using gcloud CLI
- **Python Script**: Programmatic deployment using Google Cloud SDK
- **Terraform Example**: Infrastructure as Code approach
- **Comprehensive Documentation**: Setup guide, testing procedures, and troubleshooting

## Quick Start

```bash
# Using the bash script
cd gcp-org-policy
export ORGANIZATION_ID="123456789012"
./deploy-n2d-constraint.sh

# Or using Python
pip install google-cloud-org-policy
python deploy_constraint.py --organization-id 123456789012

# Or using Terraform
cd gcp-org-policy
terraform init
terraform apply -var="organization_id=123456789012"
```

For detailed instructions, see [gcp-org-policy/README.md](gcp-org-policy/README.md)

## What This Policy Does

- **Restricts** all Compute Engine VM creation to N2D machine types only
- **Enforces** compliance at the organization, folder, or project level
- **Uses** Common Expression Language (CEL) condition: `resource.machineType.contains('/machineTypes/n2d')`
- **Helps** with cost optimization and standardization

---

# Notes
This postman collection is currently updated for version 1.9.0 of the TCGPlayer API.  When a new version come out this section will be updated and the collection will also be updated.

If you have any questions please feel free to reach out on our [community forums](https://community.tcgplayer.com)!




Repository published by Joshua Burdick, Developer Evangelist at TCGPlayer.com
