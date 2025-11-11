# Terraform configuration to create and enforce a custom organization policy
# that only allows N2D machine types for Compute Engine instances
#
# Prerequisites:
# - Terraform >= 1.0
# - Google Cloud provider configured
# - Organization admin permissions

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Variables
variable "organization_id" {
  description = "The numeric ID of the organization"
  type        = string
}

# Create the custom constraint
resource "google_org_policy_custom_constraint" "n2d_only_vms" {
  name         = "custom.createOnlyN2DVMs"
  parent       = "organizations/${var.organization_id}"

  display_name = "Only N2D VMs allowed"
  description  = "Restrict all VMs created to only use N2D machine types"

  action_type  = "ALLOW"
  condition    = "resource.machineType.contains('/machineTypes/n2d')"

  method_types = ["CREATE"]

  resource_types = [
    "compute.googleapis.com/Instance"
  ]
}

# Enforce the custom constraint with an organization policy
resource "google_org_policy_policy" "n2d_only_policy" {
  name   = "${google_org_policy_custom_constraint.n2d_only_vms.parent}/policies/${google_org_policy_custom_constraint.n2d_only_vms.name}"
  parent = "organizations/${var.organization_id}"

  spec {
    rules {
      enforce = "TRUE"
    }
  }

  depends_on = [google_org_policy_custom_constraint.n2d_only_vms]
}

# Outputs
output "constraint_name" {
  description = "The name of the custom constraint"
  value       = google_org_policy_custom_constraint.n2d_only_vms.name
}

output "constraint_id" {
  description = "The full resource name of the custom constraint"
  value       = "${google_org_policy_custom_constraint.n2d_only_vms.parent}/customConstraints/${google_org_policy_custom_constraint.n2d_only_vms.name}"
}

output "policy_name" {
  description = "The name of the organization policy"
  value       = google_org_policy_policy.n2d_only_policy.name
}

# Example usage:
#
# 1. Create a terraform.tfvars file:
#    organization_id = "123456789012"
#
# 2. Initialize Terraform:
#    terraform init
#
# 3. Plan the deployment:
#    terraform plan
#
# 4. Apply the configuration:
#    terraform apply
#
# 5. To create an exception for a specific project:
#
# resource "google_org_policy_policy" "n2d_exception_project" {
#   name   = "projects/${var.project_id}/policies/custom.createOnlyN2DVMs"
#   parent = "projects/${var.project_id}"
#
#   spec {
#     rules {
#       enforce = "FALSE"
#     }
#   }
# }
