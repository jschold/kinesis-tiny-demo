provider "aws" {
  profile    = "default"
  region     = "us-west-2"
}

resource "aws_kinesis_stream" "test_stream" {
  name             = "terraform-kinesis-test"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags = {
    Environment = "test"
  }
}

resource "aws_lambda_function" "process_lambda" {
  s3_bucket = "my-cigna-bucket"
  s3_key    = "lambda.zip"
  function_name    = "process_lambda"
  handler          = "process_data.lambda_handler"
  runtime          = "python3.8"
  timeout          = 180
  role = "${aws_iam_role.lambda_exec_role.arn}"
}

resource "aws_lambda_function" "publish_lambda" {
  s3_bucket = "my-cigna-bucket"
  s3_key    = "lambda.zip"
  function_name    = "publish_lambda"
  handler          = "publish_data.lambda_handler"
  runtime          = "python3.8"
  timeout          = 180
  role = "${aws_iam_role.lambda_exec_role.arn}"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}