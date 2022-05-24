resource "aws_backup_vault" "tdcs_efs_backup" {
  name        = "tdcs-dev-an2-backuprule-efs-applog"

  tags = {
      "Name"  = "${local.project_id}-${local.env}-backuprule-efs-applog"
      "creator" = "P092913",
      "operator1" = "P092913",
      "operator2" = "P069329"
    }
}

resource "aws_backup_plan" "tdcs_efs_backup" {
  name        = "${local.project_id}-${local.env}-an2-backupplan-efs-applog"

  rule {
    rule_name         = "${local.project_id}-${local.env}-an2-backuprule-efs-applog"
    target_vault_name = aws_backup_vault.tdcs_efs_backup.name
    schedule          = "cron(0 14 ? * * *)"
    start_window      = 60
    completion_window = 120
    enable_continuous_backup = false

   lifecycle {
    cold_storage_after = 14
    delete_after = 0
    }
  }

  tags = {
      "Name"  = "${local.project_id}${local.env}-an2-backupplan-efs-applog"
      "creator" = "P092913",
      "operator1" = "P092913",
      "operator2" = "P069329"
    }
}

resource "aws_backup_selection" "tdcs_efs_backup" {
  iam_role_arn = aws_iam_role.tdcs_role_backup.arn
  name         = "backup_selection"
  plan_id      = aws_backup_plan.tdcs_efs_backup.id

  resources = [data.terraform_remote_state.efs.outputs.tdcs_efs_applog_arn]
}