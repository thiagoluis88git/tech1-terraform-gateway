import json
import base64
import boto3
from botocore.exceptions import ClientError

def generate_policy(principal_id, effect, resource):
    auth_response = {
        'principalId': principal_id
    }

    if effect and resource:
        policy_document = {
            'Version': '2012-10-17',
            'Statement': [
                {
                    'Action': 'execute-api:invoke',
                    'Effect': effect,
                    'Resource': resource
                }
            ]
        }
        auth_response['policyDocument'] = policy_document

    return auth_response

def verify_access_token(access_token, path):
    # Initialize a boto3 client for Cognito
    client = boto3.client('cognito-idp', region_name="us-east-1")

    try:
        # Call GetUser API with the provided access token
        response = client.get_user(
            AccessToken=access_token
        )
        
        # If the access token is valid, you will get user information
        print("Access token is valid!")
        print("User attributes:", response)
        
        tokenSplitted = access_token.split(".")

        userDataBytes = base64.b64decode(tokenSplitted[1] + "==")

        userData = userDataBytes.decode("utf-8")
        
        userDataDict = json.loads(userData)

        return check_user_group(userDataDict["cognito:groups"], path)
    
    except ClientError as e:
        # Handle exceptions (such as invalid token)
        if e.response['Error']['Code'] == 'NotAuthorizedException':
            print("Access token is invalid.")
        else:
            print(f"An error occurred: {e}")
        
        return False

def check_user_group(group, path):
    if path.find("/admin/") and "group-admin" not in group:
        return False
    
    if path.find("/api/") and ("group-admin" not in group or "group-users" not in group):
        return False
    
    return True

def check_path(path, token):
    if path.find("/auth/") > 0:
        return True
    if path.find("/health") > 0:
        return True
    if path.find("/swagger/") > 0:
        return True
    
    return verify_access_token(token, path)

def lambda_handler(event, context):
    token = event['authorizationToken']

    # Ex: arn:aws:execute-api:us-east-1:714167738697:d5f2gzii64/prd/GET/api/products/3
    methodArn = event['methodArn']

    isValid = check_path(methodArn, token)

    if not isValid:
        return generate_policy('user', 'Deny', methodArn)
    
    return generate_policy('user', 'Allow', methodArn)