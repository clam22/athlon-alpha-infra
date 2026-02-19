data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["${var.service_name}.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "iam_role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_policy" "serice_role_iam_policy" {
  name   = "${var.role_name}-policy"
  policy = var.iam_service_role_policy_json
}

resource "aws_iam_policy_attachment" "iam_role_policy_attachment" {
  name       = "${var.role_name}-policy-attachment"
  roles      = [aws_iam_role.iam_role.name]
  policy_arn = aws_iam_policy.serice_role_iam_policy.arn
}