provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "s3" {
    bucket = "proj3-tf-bucket"
    force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "s3" {
    bucket = aws_s3_bucket.s3.id
    block_public_acls = false
    block_public_policy = false
}

// Terraform uses the following logic:
// Ongoing lifecyle: according to the first matched rule = 365 days
// During destroy: according to the minimal setting across all rules = 0 days = immediate deletion
resource "aws_s3_bucket_lifecycle_configuration" "s3" {
  rule {
    id      = "AutoDeleteAfter365Days"
    status  = "Enabled"
    prefix  = ""   # Leave this empty to apply the rule to the entire bucket
    enabled = true

    # Expiration rule for automatic deletion after 365 days = 1 year
    expiration {
      days = 365
    }
  }

  rule {
    id      = "DeleteDuringDestroy"
    status  = "Enabled"
    prefix  = ""   # Leave this empty to apply the rule to the entire bucket
    enabled = true

    # Expiration rule for immediate deletion during destroy
    expiration {
      days = 0
    }
  }
}