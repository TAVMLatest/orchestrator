#!/bin/bash

# Ensure the required environment variables are set
if [ -z "$GITHUB_APP_ID" ] || [ -z "$GITHUB_APP_PRIVATE_KEY" ]; then
    echo "GITHUB_APP_ID and GITHUB_APP_PRIVATE_KEY environment variables must be set."
    exit 1
fi

# Install required gems if not already present
if ! gem list -i jwt > /dev/null 2>&1; then
    echo "Installing JWT gem..."
    gem install jwt --no-document
fi

# Generate the JWT token
JWT_TOKEN=$(ruby -r jwt -r openssl -r base64 -e '
private_key = OpenSSL::PKey::RSA.new(ENV["GITHUB_APP_PRIVATE_KEY"])
payload = {
  iat: Time.now.to_i,
  exp: Time.now.to_i + (10 * 60),
  iss: ENV["GITHUB_APP_ID"]
}
token = JWT.encode(payload, private_key, "RS256")
puts token
')

# Check if JWT token generation was successful
if [ -z "$JWT_TOKEN" ]; then
    echo "Failed to generate JWT token."
    exit 1
fi

# Output the JWT token
echo "$JWT_TOKEN"