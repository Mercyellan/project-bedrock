import json
import urllib.parse


def handler(event, context):
    """
    Lambda function to process S3 upload events.
    Logs the name of the uploaded file to CloudWatch.
    """
    for record in event.get("Records", []):
        # Get bucket name
        bucket = record["s3"]["bucket"]["name"]

        # Get the object key (filename) and decode URL encoding
        key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])

        # Log the image received message
        print(f"Image received: {key}")

        # Additional logging for debugging
        print(f"Bucket: {bucket}")
        print(f"Event time: {record.get('eventTime', 'unknown')}")
        print(f"Event name: {record.get('eventName', 'unknown')}")

    return {"statusCode": 200, "body": json.dumps("Asset processed successfully!")}