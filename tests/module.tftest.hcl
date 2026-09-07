mock_provider "databricks" {}

variables {

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

run "documented_example" {
  command = apply

  assert {
    condition     = databricks_cluster_policy.this.name == var.name
    error_message = "The resource must preserve its configured name."
  }

  assert {
    condition     = length(databricks_permissions.this) == 1
    error_message = "Configured access must have stable resource addresses."
  }
}

run "without_access" {
  command = plan

  variables {
    permissions = []
  }

  assert {
    condition     = length(databricks_permissions.this) == 0
    error_message = "Empty access must omit the access resources."
  }
}
