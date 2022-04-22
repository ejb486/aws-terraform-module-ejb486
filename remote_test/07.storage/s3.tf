
################################################################################
################################################################################
#####                                                                      #####
#####   					  s3를 생성합니다. 		     	                   #####
#####                                                                      #####
################################################################################
################################################################################


################################################################################
#####   						s3 생성       							#####
################################################################################
resource "aws_s3_bucket" "s3-application" {
  bucket = "${local.project_id}-${local.env}-s3-application"
#  acl    = "private"
  
#  bucket_server_side_encryption_configuration {
#    rule {
#      apply_server_side_encryption_by_default {
#        sse_algorithm = "AES256"
#      }
#    }
#  }
  
  tags = {
    "creator"   = "P092913"
    "operator1" = "P067880"
    "operator2" = "P069397"
  }
}

################################################################################
#####   						속성 중 암호화 설정       					#####
################################################################################
resource "aws_s3_bucket_server_side_encryption_configuration" "s3-application-config" {
  bucket = aws_s3_bucket.s3-application.id

  rule {
    apply_server_side_encryption_by_default {
#      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "AES256"
    }
  }
}



#resource "aws_s3_bucket_policy" "s3-application-accesslogging" {
#  bucket = "smp-prd-an2-s3-application-accesslogging-test2"
##  acl    = "private"
#  policy =<<POLICY
#  {
#    "Version": "2012-10-17",
#    "Id": "S3-Console-Auto-Gen-Policy-1648028110544",
#    "Statement": [
#        {
#            "Sid": "S3PolicyStmt-DO-NOT-MODIFY-1648028110465",
#            "Effect": "Allow",
#            "Principal": {
#                "Service": "logging.s3.amazonaws.com"
#            },
#            "Action": "s3:PutObject",
#            "Resource": "arn:aws:s3:::smp-prd-an2-s3-application-accesslogging-test2/*"
#        }
#    ]
#  }
#  POLICY
#}

################################################################################
#####   						s3 생성       							#####
################################################################################
resource "aws_s3_bucket" "s3-application-accesslogging" {
  bucket = "${local.project_id}-${local.env}-s3-application-accesslogging"
}

################################################################################
#####   						정책 설정       							#####
################################################################################
resource "aws_s3_bucket_policy" "s3-application-accesslogging-policy" {
  bucket = aws_s3_bucket.s3-application-accesslogging.id
  policy = data.aws_iam_policy_document.s3-application-accesslogging-policy-document.json
}

################################################################################
#####   						정책 내용 설정       							#####
################################################################################
data "aws_iam_policy_document" "s3-application-accesslogging-policy-document" {
  statement {  
  	sid = "S3PolicyStmt-DO-NOT-MODIFY-1648028110465"
    actions = ["s3:PutObject"]
	  resources = [
	    "arn:aws:s3:::${local.project_id}-${local.env}-s3-application-accesslogging/*"
	  ]
	  principals {
	    type = "Service"
	    identifiers  = ["logging.s3.amazonaws.com"]
	  }
  }
}

################################################################################
#####   						s3 생성       							#####
################################################################################
resource "aws_s3_bucket" "s3-eksbackup" {
  bucket = "${local.project_id}-${local.env}-s3-eksbackup"
#  acl    = "private"
  
#  bucket_server_side_encryption_configuration {
#    rule {
#      apply_server_side_encryption_by_default {
#        sse_algorithm = "AES256"
#      }
#    }
#  }
  
  tags = {
    "creator"   = "P092913"
    "operator1" = "P067880"
    "operator2" = "P069397"
  }
}


################################################################################
#####   						속성 중 암호화 설정       					#####
################################################################################
resource "aws_s3_bucket_server_side_encryption_configuration" "s3-eksbackup-config" {
  bucket = aws_s3_bucket.s3-eksbackup.id

  rule {
    apply_server_side_encryption_by_default {
#      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "AES256"
    }
  }
}



#resource "aws_s3_bucket_policy" "s3-eksbackup-accesslogging" {
#  bucket = "smp-prd-an2-s3-eksbackup-accesslogging-test4"
##  acl    = "private"
#  policy = <<POLICY
#  {
#    "Version": "2012-10-17",
#    "Id": "S3-Console-Auto-Gen-Policy-1648028128033",
#    "Statement": [
#        {
#            "Sid": "S3PolicyStmt-DO-NOT-MODIFY-1648028127935",
#            "Effect": "Allow",
#            "Principal": {
#                "Service": "logging.s3.amazonaws.com"
#            },
#            "Action": "s3:PutObject",
#            "Resource": "arn:aws:s3:::smp-prd-an2-s3-eksbackup-accesslogging/*"
#        }
#    ]
#  }
#  POLICY
#}

################################################################################
#####   						s3 생성       							#####
################################################################################
resource "aws_s3_bucket" "s3-eksbackup-accesslogging" {
  bucket = "${local.project_id}-${local.env}-s3-eksbackup-accesslogging"
}

################################################################################
#####   						정책 설정       							#####
################################################################################
resource "aws_s3_bucket_policy" "s3-eksbackup-accesslogging-policy" {
  bucket = aws_s3_bucket.s3-eksbackup-accesslogging.id
  policy = data.aws_iam_policy_document.s3-eksbackup-accesslogging-policy-document.json
}

################################################################################
#####   						정책 내용 설정       							#####
################################################################################
data "aws_iam_policy_document" "s3-eksbackup-accesslogging-policy-document" {
  statement {  
	  sid = "S3PolicyStmt-DO-NOT-MODIFY-1648028127935"
    actions = ["s3:PutObject"]
	  resources = [
	    "arn:aws:s3:::${local.project_id}-${local.env}-s3-eksbackup-accesslogging/*"
	  ]
	  principals {
	    type = "Service"
	    identifiers  = ["logging.s3.amazonaws.com"]
	  }
  }
}

