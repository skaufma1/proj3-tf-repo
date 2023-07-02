provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "s3" {
    bucket = "proj3-tf-bucket"
}

resource "aws_s3_bucket_public_access_block" "s3" {
    bucket = aws_s3_bucket.s3.id
    block_public_acls = false
    block_public_policy = false
}