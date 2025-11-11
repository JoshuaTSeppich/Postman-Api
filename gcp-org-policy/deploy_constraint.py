#!/usr/bin/env python3
"""
Python script to create and enforce a custom organization policy
that only allows N2D machine types for Compute Engine instances.

Prerequisites:
- pip install google-cloud-org-policy
- gcloud auth application-default login
- Organization admin permissions

Usage:
    python deploy_constraint.py --organization-id 123456789012
"""

import argparse
import sys
from typing import Optional

try:
    from google.cloud import orgpolicy_v2
    from google.api_core import exceptions
except ImportError:
    print("Error: google-cloud-org-policy not installed")
    print("Install with: pip install google-cloud-org-policy")
    sys.exit(1)


class N2DConstraintDeployer:
    """Deploys custom organization policy constraint for N2D-only VMs."""

    CONSTRAINT_ID = "custom.createOnlyN2DVMs"
    DISPLAY_NAME = "Only N2D VMs allowed"
    DESCRIPTION = "Restrict all VMs created to only use N2D machine types"
    CONDITION = "resource.machineType.contains('/machineTypes/n2d')"
    RESOURCE_TYPE = "compute.googleapis.com/Instance"

    def __init__(self, organization_id: str):
        """
        Initialize the deployer.

        Args:
            organization_id: The numeric organization ID
        """
        self.organization_id = organization_id
        self.org_policy_client = orgpolicy_v2.OrgPolicyClient()
        self.parent = f"organizations/{organization_id}"

    def create_custom_constraint(self) -> bool:
        """
        Create the custom constraint.

        Returns:
            True if successful, False otherwise
        """
        print(f"Creating custom constraint: {self.CONSTRAINT_ID}")
        print(f"Organization: {self.parent}")

        constraint = orgpolicy_v2.CustomConstraint(
            name=f"{self.parent}/customConstraints/{self.CONSTRAINT_ID}",
            display_name=self.DISPLAY_NAME,
            description=self.DESCRIPTION,
            condition=self.CONDITION,
            action_type=orgpolicy_v2.CustomConstraint.ActionType.ALLOW,
            method_types=[orgpolicy_v2.CustomConstraint.MethodType.CREATE],
            resource_types=[self.RESOURCE_TYPE],
        )

        request = orgpolicy_v2.CreateCustomConstraintRequest(
            parent=self.parent,
            custom_constraint=constraint,
        )

        try:
            response = self.org_policy_client.create_custom_constraint(request=request)
            print(f"✓ Custom constraint created: {response.name}")
            return True
        except exceptions.AlreadyExists:
            print(f"⚠ Custom constraint already exists: {constraint.name}")
            return True
        except Exception as e:
            print(f"✗ Error creating custom constraint: {e}")
            return False

    def enforce_constraint(self) -> bool:
        """
        Create and enforce the organization policy.

        Returns:
            True if successful, False otherwise
        """
        print(f"\nEnforcing organization policy for: {self.CONSTRAINT_ID}")

        policy_name = f"{self.parent}/policies/{self.CONSTRAINT_ID}"

        policy = orgpolicy_v2.Policy(
            name=policy_name,
            spec=orgpolicy_v2.PolicySpec(
                rules=[
                    orgpolicy_v2.PolicySpec.PolicyRule(
                        enforce=True,
                    )
                ]
            ),
        )

        request = orgpolicy_v2.CreatePolicyRequest(
            parent=self.parent,
            policy=policy,
        )

        try:
            response = self.org_policy_client.create_policy(request=request)
            print(f"✓ Organization policy created and enforced: {response.name}")
            return True
        except exceptions.AlreadyExists:
            # Policy exists, try to update it
            try:
                update_request = orgpolicy_v2.UpdatePolicyRequest(policy=policy)
                response = self.org_policy_client.update_policy(request=update_request)
                print(f"✓ Organization policy updated: {response.name}")
                return True
            except Exception as e:
                print(f"✗ Error updating policy: {e}")
                return False
        except Exception as e:
            print(f"✗ Error creating policy: {e}")
            return False

    def verify_deployment(self) -> bool:
        """
        Verify the constraint and policy are deployed.

        Returns:
            True if verified, False otherwise
        """
        print("\nVerifying deployment...")

        try:
            # Check custom constraint
            constraint_name = f"{self.parent}/customConstraints/{self.CONSTRAINT_ID}"
            constraint = self.org_policy_client.get_custom_constraint(name=constraint_name)
            print(f"✓ Custom constraint verified: {constraint.name}")

            # Check policy
            policy_name = f"{self.parent}/policies/{self.CONSTRAINT_ID}"
            policy = self.org_policy_client.get_policy(name=policy_name)
            print(f"✓ Organization policy verified: {policy.name}")

            is_enforced = any(rule.enforce for rule in policy.spec.rules)
            print(f"  Enforcement status: {'Enabled' if is_enforced else 'Disabled'}")

            return True
        except Exception as e:
            print(f"✗ Verification failed: {e}")
            return False

    def deploy(self) -> bool:
        """
        Execute full deployment: create constraint and enforce policy.

        Returns:
            True if successful, False otherwise
        """
        print("=" * 70)
        print("Google Cloud Custom Organization Policy Deployment")
        print("Constraint: N2D Machine Types Only")
        print("=" * 70)
        print()

        # Step 1: Create custom constraint
        if not self.create_custom_constraint():
            return False

        # Step 2: Enforce the constraint
        if not self.enforce_constraint():
            return False

        # Step 3: Verify deployment
        if not self.verify_deployment():
            return False

        print("\n" + "=" * 70)
        print("Deployment completed successfully!")
        print("=" * 70)
        print("\nPolicy Summary:")
        print(f"  Constraint ID: {self.CONSTRAINT_ID}")
        print(f"  Organization: {self.parent}")
        print(f"  Effect: Only allows VM instances with N2D machine types")
        print(f"  Scope: Organization-wide")
        print("\nNote: Policy changes may take a few minutes to propagate.")
        print("\nTest commands:")
        print("  # This should fail:")
        print("  gcloud compute instances create test-vm --machine-type=e2-medium --zone=us-central1-a")
        print("\n  # This should succeed:")
        print("  gcloud compute instances create test-vm --machine-type=n2d-standard-2 --zone=us-central1-a")

        return True


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Deploy N2D-only custom organization policy constraint"
    )
    parser.add_argument(
        "--organization-id",
        required=True,
        help="Google Cloud organization ID (numeric)",
    )
    parser.add_argument(
        "--verify-only",
        action="store_true",
        help="Only verify existing deployment without creating",
    )

    args = parser.parse_args()

    deployer = N2DConstraintDeployer(args.organization_id)

    if args.verify_only:
        success = deployer.verify_deployment()
    else:
        success = deployer.deploy()

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
