import boto3
import json

def lambda_handler(event, context):
    client = boto3.client('kinesis')
    client.put_record("terraform-kinesis-test", json.dumps("i am a message"), "partitionkey")
