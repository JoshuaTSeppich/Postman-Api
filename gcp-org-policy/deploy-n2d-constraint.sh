#!/bin/bash

# Script to create and enforce a custom organization policy constraint
# that only allows N2D machine types for Compute Engine instances
#
# Prerequisites:
# - gcloud CLI installed and authenticated
# - Organization admin permissions
# - Replace ORGANIZATION_ID and PROJECT_ID with your actual values

set -e

# Configuration variables
ORGANIZATION_ID="${ORGANIZATION_ID:-YOUR_ORG_ID}"
PROJECT_ID="${PROJECT_ID:-YOUR_PROJECT_ID}"
CONSTRAINT_ID="custom.createOnlyN2DVMs"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Creating custom organization policy constraint for N2D-only VMs${NC}"
echo ""

# Validate that ORGANIZATION_ID is set
if [ "$ORGANIZATION_ID" = "YOUR_ORG_ID" ]; then
    echo -e "${RED}Error: Please set ORGANIZATION_ID environment variable or update the script${NC}"
    echo "Usage: ORGANIZATION_ID=123456789 PROJECT_ID=my-project ./deploy-n2d-constraint.sh"
    exit 1
fi

echo -e "${YELLOW}Step 1: Creating custom constraint${NC}"
echo "Organization ID: $ORGANIZATION_ID"
echo "Constraint ID: $CONSTRAINT_ID"
echo ""

# Create the custom constraint using YAML file
gcloud org-policies set-custom-constraint \
    custom-constraint-n2d-only.yaml \
    --organization="$ORGANIZATION_ID" \
    || { echo -e "${RED}Failed to create custom constraint${NC}"; exit 1; }

echo -e "${GREEN}✓ Custom constraint created successfully${NC}"
echo ""

# Create the organization policy YAML
echo -e "${YELLOW}Step 2: Creating organization policy to enforce the constraint${NC}"

cat > org-policy-n2d-only.yaml <<EOF
name: organizations/$ORGANIZATION_ID/policies/custom.createOnlyN2DVMs
spec:
  rules:
  - enforce: true
EOF

# Apply the organization policy
gcloud org-policies set-policy \
    org-policy-n2d-only.yaml \
    --organization="$ORGANIZATION_ID" \
    || { echo -e "${RED}Failed to set organization policy${NC}"; exit 1; }

echo -e "${GREEN}✓ Organization policy enforced successfully${NC}"
echo ""

echo -e "${GREEN}Deployment completed!${NC}"
echo ""
echo -e "${YELLOW}Policy Summary:${NC}"
echo "- Constraint: organizations/$ORGANIZATION_ID/customConstraints/$CONSTRAINT_ID"
echo "- Effect: Only allows VM instances with N2D machine types"
echo "- Scope: Organization-wide (can be overridden at folder/project level)"
echo ""
echo -e "${YELLOW}Note:${NC} Policy changes may take a few minutes to propagate."
echo ""
echo "To test the policy, try creating a VM with a non-N2D machine type:"
echo "  gcloud compute instances create test-vm --machine-type=e2-medium --zone=us-central1-a"
echo ""
echo "To create a VM with an allowed N2D machine type:"
echo "  gcloud compute instances create test-vm --machine-type=n2d-standard-2 --zone=us-central1-a"
