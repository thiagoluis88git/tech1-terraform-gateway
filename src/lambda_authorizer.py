import json

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


def lambda_handler(event, context):
    token = event['authorizationToken']

    valid_token = 'xyz987'

    if token == valid_token:
        return generate_policy('user', 'Allow', event['methodArn'])
    else:
        return generate_policy('user', 'Deny', event['methodArn'])