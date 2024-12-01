#!/usr/bin/env python3
import os
import time
import jwt
import requests

# Ensure the required environment variables are set
required_vars = ['GITHUB_APP_ID', 'GITHUB_APP_PEM_FILE', 'GITHUB_APP_INSTALLATION_ID']
for var in required_vars:
    if var not in os.environ:
        print(f"{var} environment variable must be set.")
        exit(1)

# Generate the JWT token
payload = {
    'iat': int(time.time()),
    'exp': int(time.time()) + 600,  # 10 minutes
    'iss': os.environ['GITHUB_APP_ID']
}

private_key = os.environ['GITHUB_APP_PEM_FILE']
jwt_token = jwt.encode(payload, private_key, algorithm="RS256")

# Use the JWT to get an installation token
installation_id = os.environ['GITHUB_APP_INSTALLATION_ID']
url = f"https://api.github.com/app/installations/{installation_id}/access_tokens"
headers = {
    "Authorization": f"Bearer {jwt_token}",
    "Accept": "application/vnd.github.v3+json"
}

response = requests.post(url, headers=headers)

if response.status_code == 201:
    installation_token = response.json()['token']
    print(installation_token)
else:
    print(f"Error getting installation token: {response.status_code}")
    print(response.text)
    exit(1)