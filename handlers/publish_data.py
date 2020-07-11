from boto3 import kinesis

def lambda_handler(event, context):
    kinesis.put_record("terraform-kinesis-test", json.dumps("i am a message"), "partitionkey")
