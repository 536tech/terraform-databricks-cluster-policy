# Databricks cluster policy Terraform module

One cluster policy.

Creates one cluster policy and, when `permissions` is not empty, one `databricks_permissions` block on it. The module encodes `definition` and `policy_family_definition_overrides` to JSON, so pass them as objects.

## Resources

- `databricks_cluster_policy.this`
- `databricks_permissions.this[0]` (count = 1 only when `permissions` is not empty)

The resource addresses above are part of the DataTF import contract. Do not rename them.

## Usage

```hcl
module "cluster_policy" {
  source  = "536tech/cluster-policy/databricks"
  version = "1.0.0"

  name        = "Team Policy"
  description = "Pinned runtime for team clusters"

  definition = {
    spark_version = {
      type  = "fixed"
      value = "15.4.x-scala2.12"
    }
  }

  libraries = [{
    pypi = {
      package = "great-expectations==0.18.0"
    }
  }]

  permissions = [{
    permission_level = "CAN_USE"
    group_name       = "data-engineers"
  }]
}
```

## Compatibility

Configure the Databricks provider in the calling root with a workspace endpoint.
This resource module is also used by the
[workspace pattern module](https://registry.terraform.io/modules/536tech/workspace/databricks/latest).
Each repository has its own releases. Consumers select an exact tested module version.

The resource addresses match the original workspace submodule in version 0.1.1.
To migrate a direct submodule call, change its source and version. Keep the module block name.
Run `terraform init` and require a plan with no resource changes.
DataTF exports continue to use the workspace pattern module and its existing import addresses.

## Development

Use Terraform 1.7 or later for the mock tests. The module supports Terraform 1.5 or later.

```sh
prek install
terraform init -backend=false -lockfile=readonly
terraform validate
terraform test
tflint --recursive
prek run --all-files
```

CI tests the committed provider version and the minimum supported provider, 1.128.0.
The workspace pattern module checks the complete DataTF contract and its integration behavior.

## License

[Apache-2.0](LICENSE).

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- terraform (>= 1.5.0)

- databricks (>= 1.128.0, < 2.0.0)

## Providers

The following providers are used by this module:

- databricks (>= 1.128.0, < 2.0.0)

## Resources

The following resources are used by this module:

- [databricks_cluster_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster_policy) (resource)
- [databricks_permissions.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions) (resource)

## Required Inputs

The following input variables are required:

### name

Description: Cluster policy name.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### definition

Description: Policy definition as an object. The module encodes it to JSON.

Type: `any`

Default: `null`

### description

Description: Cluster policy description.

Type: `string`

Default: `null`

### libraries

Description: Libraries installed on every cluster that uses the policy. Each element sets one of  
pypi, maven, cran, whl, jar, egg, or requirements.

Type: `any`

Default: `[]`

### max\_clusters\_per\_user

Description: Maximum number of clusters one user can start with this policy.

Type: `number`

Default: `null`

### permissions

Description: Direct permissions on the policy. Each element names exactly one principal.

Type:

```hcl
list(object({
    permission_level       = string
    group_name             = optional(string)
    user_name              = optional(string)
    service_principal_name = optional(string)
  }))
```

Default: `[]`

### policy\_family\_definition\_overrides

Description: Overrides on the policy family, as an object. The module encodes it to JSON.

Type: `any`

Default: `null`

### policy\_family\_id

Description: Policy family to derive the policy from, for example job-cluster.

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### id

Description: Cluster policy id.

### name

Description: Cluster policy name.
<!-- END_TF_DOCS -->
