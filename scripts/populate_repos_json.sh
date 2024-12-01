#!/bin/bash

# Ensure the repos.json file exists
if [ ! -f terraform/repos.json ]; then
  echo "The file terraform/repos.json does not exist. Creating it now."
  touch terraform/repos.json
fi

# Define the organization and search queries
ORG="Azure"
SEARCH_QUERY1="terraform-avm"
SEARCH_QUERY2="terraform-azurerm-avm"

# Fetch the repositories and dump to a temporary JSON file
gh repo list $ORG --limit 5000 --json name,description > repos_full.json

# Check if the temporary JSON file is empty
if [ ! -s repos_full.json ]; then
  echo "No repositories found in the $ORG organization."
  rm repos_full.json
  exit 0
fi

# Clear the existing repos.json file
echo "[]" > terraform/repos.json

# Filter the repositories and populate the repos.json file
jq --arg search_query1 "$SEARCH_QUERY1" --arg search_query2 "$SEARCH_QUERY2" '[.[] | select(.name | startswith($search_query1) or startswith($search_query2))]' repos_full.json > terraform/repos.json

# Clean up the temporary JSON file
# rm repos_full.json

echo "repos.json file has been populated."
