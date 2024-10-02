#!/bin/sh

# Input JSON
server_response='{"problem":"9082 / 8857 = ?"}'

# Extract problem from JSON
problem=$(echo "$server_response" | jq -r ".problem")

# First check: problem format
if ! echo "$problem" | grep -Eq '^-?[0-9]+[[:space:]]*[+-][[:space:]]*[0-9]+[[:space:]]*=[[:space:]]*\?$'; then
        answer="Invalid problem"    
else
    # Parse the problem
    a=$(echo $problem | awk '{print $1}')
    op=$(echo $problem | awk '{print $2}')
    b=$(echo $problem | awk '{print $3}')

    # Second check: a and b restrictions
    if [ $a -lt -10000 ] || [ $a -gt 10000 ] || [ $b -lt 0 ] || [ $b -gt 10000 ]; then
        answer="Invalid problem"
    else
        # Third check: perform arithmetic and check c restriction
        if [ "$op" = "+" ]; then
            result=$((a + b))
        else
            result=$((a - b))
        fi

        if [ $result -lt -20000 ] || [ $result -gt 20000 ]; then
            answer="Invalid problem"
        else
            answer=$result
        fi
    fi
fi

# Simulate POST request (replace with actual curl command if needed)
echo "Simulated POST request: $server_response"
echo "Answer: $answer"

# Uncomment the following line to make an actual HTTP request
# response=$(curl -X POST -H "Content-Type: application/json" -d "{\"answer\": \"$answer\"}" "http://10.113.0.253/tasks/$task_id/submit")
# echo "Submission response: $response"
