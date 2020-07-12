provider "aws" {
  profile    = "default"
  region     = "us-west-2"
}

resource "aws_kinesis_stream" "test_stream" {
  name             = "terraform-kinesis-test"
  shard_count      = 1
  retention_period = 48

  tags = {
    Environment = "test"
  }
}

resource "aws_lambda_function" "process_lambda" {
  s3_bucket = "my-cigna-bucket"
  s3_key    = "lambda.zip"
  function_name    = "process_lambda"
  handler          = "handlers/process_data.lambda_handler"
  runtime          = "python3.8"
  timeout          = 180
  role = "${aws_iam_role.lambda_exec_role.arn}"
}

resource "aws_lambda_function" "publish_lambda" {
  s3_bucket = "my-cigna-bucket"
  s3_key    = "lambda.zip"
  function_name    = "publish_lambda"
  handler          = "handlers/publish_data.lambda_handler"
  runtime          = "python3.8"
  timeout          = 180
  role = "${aws_iam_role.lambda_exec_role.arn}"
}

resource "aws_lambda_event_source_mapping" "cigna" {
  event_source_arn  = "${aws_kinesis_stream.test_stream.arn}"
  function_name     = "${aws_lambda_function.process_lambda.arn}"
  starting_position = "LATEST"
}

resource "aws_iam_role_policy" "kinesis_policy" {
  name = "kinesis_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "kinesis:GetRecords",
              "kinesis:GetShardIterator",
              "kinesis:DescribeStream",
              "kinesis:ListStreams",
              "kinesis:PutRecord",
          ],
          "Resource": [
              "arn:aws:kinesis:us-west-2:399394706053:stream/*"
          ]
      },
  ]
}
  EOF
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
