provider "aws" {
    region = "us-east-1"
}

resource "aws_dynamodb_table" "my_table" {
    name           = "proj3-tf-dyndb"
    billing_mode   = "PAY_PER_REQUEST"
    hash_key       = "DateTime"

    attribute {
        name = "DateTime"
        type = "S"
    }

    attribute {
        name = "TestName"
        type = "S"
    }

    attribute {
        name = "TestRunBy"
        type = "S"
    }

    attribute {
        name = "TestStatus"
        type = "N"
    }

    # Enable public access
    stream_enabled = true
    stream_view_type = "NEW_AND_OLD_IMAGES"
}