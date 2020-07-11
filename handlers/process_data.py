import base64

def lambda_handler(event, context):
    for record in event['Records']:
       payload=base64.b64decode(record["kinesis"]["data"])
       print(f"Message: {payload}")
       