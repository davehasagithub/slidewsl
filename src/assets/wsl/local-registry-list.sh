#!/usr/bin/env bash

# List all repositories
repositories=$(curl -s http://localhost:5000/v2/_catalog | jq -r '.repositories[]')

# Iterate over each repository and list its tags
for repo in $repositories; do
  echo "Repository: $repo"
  tags=$(curl -s http://localhost:5000/v2/"$repo"/tags/list | jq -r '.tags[]')
  for tag in $tags; do
    echo "  Tag: $tag"
  done
done
