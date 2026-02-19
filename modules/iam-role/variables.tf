variable "service_name" {
  description = "The AWS service name."
  type        = string
}

variable "role_name" {
  description = "The name of role"
  type        = string
}

variable "iam_service_role_policy_json" {
  description = "The JSON service role policy document."
  type        = string
}