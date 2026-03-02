variable "account_map_enabled" {
  type        = bool
  description = <<-EOT
    Enable the account map component lookup. When disabled, use the `account_map` variable to provide static account mapping.
    EOT
  default     = true
}

variable "account_map" {
  type = object({
    full_account_map              = map(string)
    audit_account_account_name    = optional(string, "")
    root_account_account_name     = optional(string, "")
    identity_account_account_name = optional(string, "")
    aws_partition                 = optional(string, "aws")
    iam_role_arn_templates        = optional(map(string), {})
  })
  description = <<-EOT
    Static account map to use when `account_map_enabled` is `false`. Map of account names (tenant-stage format) to account IDs.
    Optional attributes support component-specific functionality (e.g., audit_account_account_name for cloudtrail).
    EOT
  default = {
    full_account_map              = {}
    audit_account_account_name    = ""
    root_account_account_name     = ""
    identity_account_account_name = ""
    aws_partition                 = "aws"
    iam_role_arn_templates        = {}
  }
}

module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.8.0"

  component   = var.account_map_component_name
  environment = var.account_map_enabled ? var.account_map_environment_name : ""
  stage       = var.account_map_enabled ? var.account_map_stage_name : ""
  tenant      = var.account_map_enabled ? var.account_map_tenant_name : ""

  bypass   = !var.account_map_enabled
  defaults = var.account_map

  context = module.this.context
}
