variable "service_name" {
  description = "The AWS service name."
  type        = string
}

variable "iam_service_role_policy_json" {
  description = "The JSON service role policy document."
  type        = string
}