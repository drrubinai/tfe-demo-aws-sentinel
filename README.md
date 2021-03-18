"# tfe-demo-aws-sentinel" 

# Sentinel policy-as-a-code - AWS Verfications

- [Sentinel](https://www.terraform.io/docs/cloud/sentinel/index.html) is an embedded policy-as-code framework integrated with the HashiCorp Enterprise products. It enables fine-grained, logic-based policy decisions, and can be extended to use information from external sources. 
-  Sentinel policies are a paid feature in Terraform Enterprise, available as part of the Team & Governance upgrade package.

## Introduction

Sentinel Policies are rules which are enforced on Terraform runs to validate that the plan and corresponding resources are in compliance with company policies. Using Sentinel with Terraform Cloud involves:

### Defining the policies 
- Policies are defined using the policy language with imports for parsing the Terraform plan, state and configuration.
### Managing policies for organizations 
- Users with permission to manage policies can add policies to their organization by configuring VCS integration or uploading policy sets through the API. They also define which workspaces the policy sets are checked against during runs. (More about permissions.)
### Enforcing policy checks on runs 
- Policies are checked when a run is performed, after the terraform plan but before it can be confirmed or the terraform apply is executed.
### Mocking Sentinel Terraform data 
- Terraform Cloud provides the ability to generate mock data for any run within a workspace. This data can be used with the Sentinel CLI to test policies before deployment.

## Prerequisites

- An upgrade license for Team & Governance upgrade package on Terraform Enterprise.

- Integration with a Version Control Repo server (GitHub, BitBucket or GitLab) is done. 

- Workspaces connected to VCS repos for Terraform and Sentinel code are created and configured as needed.  

## Main Configuration Points

### Writing Sentinel Policies - Sentinel Language
Sentinel policies themselves are defined in individual files (one per policy) in the same directory as the sentinel.hcl file. These files must match the name of the policy from the configuration file and carry the .sentinel suffix. 
```bash  - USING ctc repos - configured in local chart files
import "time"
import "tfrun"
import "timezone"

param token default "WbNKULOBheqV"
param maintenance_days default ["Friday", "Saturday", "Sunday"]
param timezone_id default "America/Los_Angeles"

tfrun_created_at = time.load(tfrun.created_at)

supported_maintenance_day = rule when tfrun.workspace.auto_apply is true {
    tfrun_created_at.add(time.hour * timezone.offset(timezone_id, token)).weekday_name in maintenance_days
}

main = rule {
    supported_maintenance_day
}
````

### Enforcement Levels
Enforcement levels in Sentinel are used for defining behavior when policies fail to evaluate successfully. Sentinel provides three enforcement modes:


```bash  - enforcement levels
- hard-mandatory requires that the policy passes. If a policy fails, the run is halted and may not be applied until the failure is resolved.
- soft-mandatory is much like hard-mandatory, but allows any user with the Manage Policies permission to override policy failures on a case-by-case basis.
- advisory will never interrupt the run, and instead will only surface policy failures as informational to the user.
````


## Constructing a policy set - sentinel.hcl

Every policy set requires a configuration file named sentinel.hcl. This configuration file defines:

Each policy that should be checked in the set.
The enforcement level of each policy in the set.
Any modules which need to be made available to policies in the set.

```bash
policy "terraform-maintenance-windows" {
  source            = "./terraform-maintenance-windows.sentinel"
  enforcement_level = "hard-mandatory"
}
```


## Mocking Terraform Sentinel Data
Mock data can be used to  test your Sentinel policies extensively before deploying them within Terraform Cloud. An important part of this process is mocking the data that you wish your policies to operate on.