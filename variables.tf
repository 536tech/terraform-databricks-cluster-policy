variable "name" {
  description = "Cluster policy name."
  type        = string
  nullable    = false

  validation {
    condition     = try(length(trimspace(var.name)) > 0, false)
    error_message = "name must not be empty or blank."
  }
}

variable "description" {
  description = "Cluster policy description."
  type        = string
  default     = null
}

variable "definition" {
  description = "Policy definition as an object. The module encodes it to JSON."
  type        = any
  default     = null
  validation {
    condition     = var.definition == null ? true : can(keys(var.definition))
    error_message = "definition must be an object, not an encoded JSON string."
  }
}

variable "policy_family_id" {
  description = "Policy family to derive the policy from, for example job-cluster."
  type        = string
  default     = null
  validation {
    condition     = var.policy_family_id == null ? true : length(trimspace(var.policy_family_id)) > 0
    error_message = "policy_family_id must be null or nonblank."
  }
}

variable "policy_family_definition_overrides" {
  description = "Overrides on the policy family, as an object. The module encodes it to JSON."
  type        = any
  default     = null
  validation {
    condition     = var.policy_family_definition_overrides == null ? true : can(keys(var.policy_family_definition_overrides))
    error_message = "policy_family_definition_overrides must be an object."
  }
}

variable "max_clusters_per_user" {
  description = "Maximum number of clusters one user can start with this policy."
  type        = number
  default     = null
  validation {
    condition     = var.max_clusters_per_user == null ? true : try(var.max_clusters_per_user >= 1 && floor(var.max_clusters_per_user) == var.max_clusters_per_user, false)
    error_message = "max_clusters_per_user must be null or an integer of at least 1."
  }
}

variable "libraries" {
  description = <<-EOT
    Libraries installed on every cluster that uses the policy. Each element sets one of
    pypi, maven, cran, whl, jar, egg, or requirements.
  EOT

  # `any`, not list(any): Terraform unifies list element types, and a pypi entry and a
  # maven entry have different shapes.
  type     = any
  default  = []
  nullable = false

  validation {
    condition = try(can(concat(var.libraries, [])) && alltrue([for library in var.libraries :
      length([for kind in ["pypi", "maven", "cran", "whl", "jar", "egg", "requirements"] : kind if try(library[kind], null) != null]) == 1
    ]), false)
    error_message = "Each library must select exactly one supported library type."
  }
}

variable "permissions" {
  description = "Direct permissions on the policy. Each element names exactly one principal."

  type = list(object({
    permission_level       = string
    group_name             = optional(string)
    user_name              = optional(string)
    service_principal_name = optional(string)
  }))

  default  = []
  nullable = false

  validation {
    condition = try(alltrue([for permission in var.permissions :
      length([for principal in [permission.group_name, permission.user_name, permission.service_principal_name] :
        principal if principal != null
      ]) == 1 &&
      alltrue([for principal in [permission.group_name, permission.user_name, permission.service_principal_name] :
        principal == null ? true : length(trimspace(principal)) > 0
      ]) && contains(["CAN_USE"], permission.permission_level)
    ]), false)
    error_message = "Each permission needs exactly one nonblank principal and a supported level: CAN_USE."
  }
}
