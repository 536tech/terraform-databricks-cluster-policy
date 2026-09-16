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

run "reject_blank_name" {
  command = plan
  variables {
    name = "  "
  }
  expect_failures = [var.name]
}

run "reject_missing_principal" {
  command = plan
  variables {
    permissions = [{ permission_level = "CAN_USE" }]
  }
  expect_failures = [var.permissions]
}

run "reject_multiple_principals" {
  command = plan
  variables {
    permissions = [{ permission_level = "CAN_USE", user_name = "user@example.com", group_name = "readers" }]
  }
  expect_failures = [var.permissions]
}

run "reject_blank_principal" {
  command = plan
  variables {
    permissions = [{ permission_level = "CAN_USE", group_name = " " }]
  }
  expect_failures = [var.permissions]
}

run "reject_invalid_permission" {
  command = plan
  variables {
    permissions = [{ permission_level = "INVALID", group_name = "readers" }]
  }
  expect_failures = [var.permissions]
}

run "reject_missing_definition" {
  command = plan
  variables {
    definition = null
  }
  expect_failures = [databricks_cluster_policy.this]
}

run "reject_definition_and_family" {
  command = plan
  variables {
    policy_family_id = "job-cluster"
  }
  expect_failures = [databricks_cluster_policy.this]
}

run "reject_multiple_library_types" {
  command = plan
  variables {
    libraries = [{ whl = "a.whl", jar = "b.jar" }]
  }
  expect_failures = [var.libraries]
}

run "accept_mixed_library_types" {
  command = plan
  variables {
    libraries = [{ pypi = { package = "pandas" } }, { maven = { coordinates = "org.example:library:1.0.0" } }]
  }
}
