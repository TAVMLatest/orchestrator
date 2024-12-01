#!/bin/bash


# Ensure the required environment variables are set
if [ -z "$GITHUB_APP_ID" ] || [ -z "$GITHUB_APP_PRIVATE_KEY" ]; then
  echo "GITHUB_APP_ID and GITHUB_APP_PRIVATE_KEY environment variables must be set."
  exit 1
fi

# Generate the JWT token
JWT_TOKEN=$(ruby -r openssl -r base64 -r json -e '
  require "jwt"

  iat = Time.now.to_i
  exp = iat + (10 * 60)
  payload = {
    iat: iat,
    exp: exp,
    iss: ENV["GITHUB_APP_ID"]
  }
  private_key = OpenSSL::PKey::RSA.new(Base64.decode64(ENV["GITHUB_APP_PRIVATE_KEY"]))
  token = JWT.encode(payload, private_key, "RS256")
  puts token
')

# Output the JWT token
echo $JWT_TOKEN
