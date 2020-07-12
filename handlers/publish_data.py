import boto3
import json


def lambda_handler(event, context):
    client = boto3.client('kinesis')
    client.put_record(StreamName="terraform-kinesis-test",
                      Data=json.dumps("i am a message"),
                      PartitionKey="partitionkey")
