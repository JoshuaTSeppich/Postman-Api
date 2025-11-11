# Google Cloud Custom Organization Policy: N2D Machine Types Only

This directory contains configuration files and scripts to create and enforce a custom Google Cloud Organization Policy that restricts Compute Engine VM creation to only N2D machine types.

## Overview

The custom constraint uses a Common Expression Language (CEL) condition to enforce that all VM instances created must use N2D machine types. This is useful for:

- **Cost optimization**: N2D instances often provide better price-performance
- **Compliance**: Enforcing AMD EPYC processor usage
- **Standardization**: Ensuring consistent machine type usage across the organization

## Files

- `custom-constraint-n2d-only.yaml`: YAML definition of the custom constraint
- `deploy-n2d-constraint.sh`: Automated deployment script
- `README.md`: This documentation file

## Prerequisites

Before deploying this policy, ensure you have:

1. **gcloud CLI** installed and authenticated
   ```bash
   gcloud auth login
   ```

2. **Organization Admin permissions** or the following IAM roles:
   - `roles/orgpolicy.policyAdmin` - To create and manage organization policies
   - `roles/compute.orgPolicyConstraintAdmin` - To create custom constraints

3. **Organization ID**: Find your organization ID
   ```bash
   gcloud organizations list
   ```

4. **Project ID**: The project where you'll test the policy

## Quick Start

### Method 1: Using the Deployment Script (Recommended)

1. Set your organization and project IDs:
   ```bash
   export ORGANIZATION_ID="123456789012"
   export PROJECT_ID="your-project-id"
   ```

2. Run the deployment script:
   ```bash
   cd gcp-org-policy
   ./deploy-n2d-constraint.sh
   ```

### Method 2: Manual Deployment

#### Step 1: Create the Custom Constraint

```bash
# Update the ORGANIZATION_ID in custom-constraint-n2d-only.yaml first
gcloud org-policies set-custom-constraint \
    custom-constraint-n2d-only.yaml \
    --organization="ORGANIZATION_ID"
```

#### Step 2: Enforce the Constraint

Create a policy file `org-policy-n2d-only.yaml`:

```yaml
name: organizations/ORGANIZATION_ID/policies/custom.createOnlyN2DVMs
spec:
  rules:
  - enforce: true
```

Apply the policy:

```bash
gcloud org-policies set-policy \
    org-policy-n2d-only.yaml \
    --organization="ORGANIZATION_ID"
```

### Method 3: Using Google Cloud Console

1. Go to the [Organization Policies page](https://console.cloud.google.com/iam-admin/orgpolicies)
2. Click **Add Custom Constraint**
3. Fill in the details:
   - **Display name**: `Only N2D VMs allowed`
   - **Constraint ID**: `custom.createOnlyN2DVMs`
   - **Description**: `Restrict all VMs created to only use N2D machine types`
   - **Resource type**: `compute.googleapis.com/Instance`
   - **Enforcement method**: Check `CREATE`
   - **Condition**: `resource.machineType.contains('/machineTypes/n2d')`
   - **Action**: `ALLOW`
4. Click **Create Constraint**
5. Find your constraint in the list and click **Manage Policy**
6. Select **Override parent's policy** and click **Add a rule**
7. Set enforcement to **On**
8. Click **Save Policy**

## Testing the Policy

### Test 1: Try Creating a Non-N2D VM (Should Fail)

```bash
gcloud compute instances create test-vm-e2 \
    --machine-type=e2-medium \
    --zone=us-central1-a \
    --project=YOUR_PROJECT_ID
```

Expected result: ❌ **Error** - Operation violates constraint `custom.createOnlyN2DVMs`

### Test 2: Create an N2D VM (Should Succeed)

```bash
gcloud compute instances create test-vm-n2d \
    --machine-type=n2d-standard-2 \
    --zone=us-central1-a \
    --project=YOUR_PROJECT_ID
```

Expected result: ✅ **Success** - VM created successfully

### Test 3: Verify the Constraint is Enforced

```bash
# List custom constraints
gcloud org-policies list-custom-constraints \
    --organization=ORGANIZATION_ID

# Get constraint details
gcloud org-policies describe \
    custom.createOnlyN2DVMs \
    --organization=ORGANIZATION_ID
```

## N2D Machine Types

N2D instances are powered by AMD EPYC processors and are available in the following configurations:

| Machine Type | vCPUs | Memory | Use Case |
|--------------|-------|---------|----------|
| n2d-standard-2 | 2 | 8 GB | General purpose |
| n2d-standard-4 | 4 | 16 GB | General purpose |
| n2d-standard-8 | 8 | 32 GB | General purpose |
| n2d-standard-16 | 16 | 64 GB | General purpose |
| n2d-standard-32 | 32 | 128 GB | General purpose |
| n2d-standard-48 | 48 | 192 GB | General purpose |
| n2d-standard-64 | 64 | 256 GB | General purpose |
| n2d-standard-80 | 80 | 320 GB | General purpose |
| n2d-standard-96 | 96 | 384 GB | General purpose |
| n2d-standard-128 | 128 | 512 GB | General purpose |
| n2d-standard-224 | 224 | 896 GB | General purpose |
| n2d-highmem-* | Various | High memory ratio | Memory-intensive workloads |
| n2d-highcpu-* | Various | Low memory ratio | CPU-intensive workloads |

[Complete list of N2D machine types](https://cloud.google.com/compute/docs/general-purpose-machines#n2d_machines)

## Policy Scope and Inheritance

The policy can be applied at different levels:

- **Organization level**: Affects all projects and folders
- **Folder level**: Affects specific folders and their projects
- **Project level**: Affects only specific projects

Child resources inherit policies from their parents, but can override them if allowed.

## Modifying the Policy

### Allow Exceptions for Specific Projects

To allow specific projects to use other machine types:

```yaml
name: projects/PROJECT_ID/policies/custom.createOnlyN2DVMs
spec:
  rules:
  - enforce: false
```

### Add Additional Allowed Machine Types

To allow N2D and E2 machine types, modify the condition in `custom-constraint-n2d-only.yaml`:

```yaml
condition: "resource.machineType.contains('/machineTypes/n2d') || resource.machineType.contains('/machineTypes/e2')"
```

Then update the constraint:

```bash
gcloud org-policies set-custom-constraint \
    custom-constraint-n2d-only.yaml \
    --organization=ORGANIZATION_ID
```

## Removing the Policy

To disable the policy enforcement:

```bash
gcloud org-policies delete \
    custom.createOnlyN2DVMs \
    --organization=ORGANIZATION_ID
```

To delete the custom constraint:

```bash
gcloud org-policies delete-custom-constraint \
    custom.createOnlyN2DVMs \
    --organization=ORGANIZATION_ID
```

## Troubleshooting

### Policy Not Taking Effect

- Wait 5-10 minutes for the policy to propagate
- Verify you have the correct organization ID
- Check if there's an override at the project or folder level

### Permission Denied Errors

Ensure you have the required IAM roles:

```bash
# Grant organization policy admin role
gcloud organizations add-iam-policy-binding ORGANIZATION_ID \
    --member="user:YOUR_EMAIL" \
    --role="roles/orgpolicy.policyAdmin"
```

### Viewing Current Policies

```bash
# List all organization policies
gcloud org-policies list \
    --organization=ORGANIZATION_ID

# Describe a specific policy
gcloud org-policies describe \
    custom.createOnlyN2DVMs \
    --organization=ORGANIZATION_ID
```

## Additional Resources

- [Google Cloud Custom Organization Policies Documentation](https://cloud.google.com/resource-manager/docs/organization-policy/creating-managing-custom-constraints)
- [CEL Language Specification](https://github.com/google/cel-spec)
- [N2D Machine Types](https://cloud.google.com/compute/docs/general-purpose-machines#n2d_machines)
- [Organization Policy Constraints](https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints)

## Support

For issues or questions:
- Review the [troubleshooting section](#troubleshooting) above
- Check Google Cloud's [organization policy documentation](https://cloud.google.com/resource-manager/docs/organization-policy)
- Contact your Google Cloud support team

---

**Note**: This policy affects all Compute Engine VM creation within the scope where it's applied. Ensure you communicate this change to your development and operations teams before enforcement.
