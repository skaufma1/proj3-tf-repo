provider "aws" {
    region = "us-east-1"
}

resource "aws_dynamodb_table" "my_table" {
    name           = "proj3-tf-dyndb"
    billing_mode   = "PROVISIONED"
    read_capacity  = 1
    write_capacity = 2
    hash_key       = "DateTime"

    attribute {
        name = "DateTime"
        type = "S"
    }

    attribute {
        name = "TestName"
        type = "S"
    }

    global_secondary_index {
        name            = "TestNameIndex"
        hash_key        = "TestName"
        projection_type = "ALL"
    }

    attribute {
        name = "TestRunBy"
        type = "S"
    }

    global_secondary_index {
        name            = "TestRunByIndex"
        hash_key        = "TestRunBy"
        projection_type = "ALL"
    }

    attribute {
        name = "TestStatus"
        type = "S"
    }

    global_secondary_index {
        name            = "TestStatusIndex"
        hash_key        = "TestStatus"
        projection_type = "ALL"
    }

    # Enable public access
    stream_enabled = true
    stream_view_type = "NEW_AND_OLD_IMAGES"
}