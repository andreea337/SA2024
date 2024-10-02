#!/bin/sh

# Perform the POST request and store the response
response=$(curl -X POST -H "Content-Type: application/json" -d '{"type":"MATH_SOLVER"}' http://10.113.0.253/tasks)

# Extract the id and type from the response using jq
id=$(echo "$response" | jq -r '.id')
type=$(echo "$response" | jq -r '.type')

# Check if id and type were successfully extracted
if [ -z "$id" ] || [ -z "$type" ]; then
    echo "Failed to extract id or type from the response"
    echo "Response: $response"
    exit 1
fi

# Invoke test1.sh with the extracted parameters
./test1.sh -p "$id" -t "$type"
