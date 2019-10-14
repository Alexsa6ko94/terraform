provider "aws" {
  region  = var.awsRegion
}

locals {
  // Get account ID
  accound_id = data.aws_caller_identity.current.account_id

  // List of the services and their permissions
  services = {
    apm-scheduler-svc = "rds"
    apm-file-synchronizer-svc = "rds"
    apm-file-storage-svc = "s3"
    apm-file-processor-svc = "rds"
    apm-file-downloader-svc = "rds"
    apm-encryption-svc = "kms"
    apm-boarding-svc = "rds"
    apm-merchant-config-svc = "rds"
  }
}

resource "aws_iam_role" "iam_role" {
  for_each = local.services

  name = "${each.key}-role"
  description = "Role used by the ${each.key} task to access ${upper(each.value)} resources"
  assume_role_policy = file("${path.module}/policies/ecs_task_assume_role.json")
}

resource "aws_iam_policy" "iam_policy" {
  for_each = local.services

  name = "${each.key}-policy"
  description = "Policy for ${each.key} to access ${upper(each.value)} resources"
  policy = file("${path.module}/policies/ecs_task_iam_${each.value}_policy.json")
}

resource "aws_iam_policy_attachment" "iam_policy_attachment" {
  depends_on = [
    aws_iam_role.iam_role,
    aws_iam_policy.iam_policy
  ]
  for_each = local.services

  name  = "${each.key}-attach"
  roles = [
    "${each.key}-role"
  ]
  policy_arn = "arn:aws:iam::${local.accound_id}:policy/${each.key}-policy"
}