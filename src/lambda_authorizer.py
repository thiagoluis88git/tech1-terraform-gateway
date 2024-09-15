import json
import boto3
from botocore.exceptions import ClientError

def generate_policy(principal_id, effect, resource):
    auth_response = {
        'principalId': principal_id
    }

    if effect and resource:
        polici_document = {
            'Version': '2012-10-17',
            'Statement': [
                {
                    'Action': 'execute-api:invoke',
                    'Effect': effect,
                    'Resource': resource
                }
            ]
        }
        auth_response['policyDocument'] = polici_document

    return auth_response

def verify_access_token(access_token):
    # Initialize a boto3 client for Cognito
    client = boto3.client('cognito-idp')

    try:
        # Call GetUser API with the provided access token
        response = client.get_user(
            AccessToken=access_token
        )
        
        # If the access token is valid, you will get user information
        print("Access token is valid!")
        print("User attributes:", response['UserAttributes'])
        
        return True
    
    except ClientError as e:
        # Handle exceptions (such as invalid token)
        if e.response['Error']['Code'] == 'NotAuthorizedException':
            print("Access token is invalid.")
        else:
            print(f"An error occurred: {e}")
        
        return False

def lambda_handler(event, context):
    token = event['authorizationToken']

    isValid = verify_access_token(token)

    print("É valido?", isValid)
    
    valid_token = 'xyz987'

    if token == valid_token:
        return generate_policy('user', 'Allow', event['methodArn'])
    else:
        return generate_policy('user', 'Deny', event['methodArn'])