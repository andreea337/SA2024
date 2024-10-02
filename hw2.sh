#!/bin/sh

usage() {
        cat << EOF >&2
hw2.sh -p TASK_ID -t TASK_TYPE [-h]
Available Options:
  -p: Task id
  -t JOIN_NYCU_CSIT|MATH_SOLVER|CRACK_PASSWORD: Task type
  -h: Show the script usage
EOF
}

task_id=""
task_type=""

while getopts "p:t:h" opt 2>/dev/null; do
    case $opt in
        p) task_id="$OPTARG" ;;
        t) task_type="$OPTARG" ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

if [ -z "$task_id" ] || [ -z "$task_type" ]; then
    usage
    exit 1
fi

# Fetch the server record
server_response=$(curl -s -X GET "http://10.113.0.253/tasks/$task_id")

# Extract the type from the server response
server_type=$(echo "$server_response" | jq -r ".type")

case "$task_type" in
    JOIN_NYCU_CSIT|MATH_SOLVER|CRACK_PASSWORD)
        # Here you would typically check the task type against the server's record
        # For demonstration purposes, we'll use a placeholder condition
        if [ "$task_type" != "$server_type" ]; then
            echo "Task type not match" >&2
            exit 1
        fi
        ;;
    *)
        echo "Invalid task type" >&2
        exit 1
        ;;
esac

# New addition for handling JOIN_NYCU_CSIT task type
if [ "$task_type" = "JOIN_NYCU_CSIT" ]; then
    response=$(curl -X POST -H "Content-Type: application/json" -d '{"answer": "I Love NYCU CSIT"}' "http://10.113.0.253/tasks/$task_id/submit")
    echo "Submission response: $response"
fi

# Handle MATH_SOLVER task type
if [ "$task_type" = "MATH_SOLVER" ]; then
    problem=$(echo "$server_response" | jq -r ".problem")

    # First check: problem format
if ! echo "$problem" | grep -Eq '^-?[0-9]+[[:space:]]*[+-][[:space:]]*[0-9]+[[:space:]]*=[[:space:]]*\?$'; then
        answer="Invalid problem"
        else
        # Parse the problem
        a=$(echo "$problem" | awk '{print $1}')
        op=$(echo "$problem" | awk '{print $2}')
        b=$(echo "$problem" | awk '{print $3}')

        # Second check: a and b restrictions
        if [ "$a" -lt -10000 ] || [ "$a" -gt 10000 ] || [ "$b" -lt 0 ] || [ "$b" -gt 10000 ]; then
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

    response=$(curl -X POST -H "Content-Type: application/json" -d "{\"answer\": \"$answer\"}" "http://10.113.0.253/tasks/$task_id/submit")
    echo "Submission response: $response"
fi

# Handle CRACK_PASSWORD task type
if [ "$task_type" = "CRACK_PASSWORD" ]; then
    problem=$(echo "$server_response" | jq -r ".problem")
    if ! echo "$problem" | grep -Eq '^[A-Z]{8}\{[A-Za-z]{16}\}$'; then
        answer="Invalid problem"
    else
    # Extract the encrypted parts
    encrypted_prefix=$(echo "$problem" | cut -d'{' -f1)
    encrypted_content=$(echo "$problem" | sed 's/^[A-Z]\{8\}{\([A-Za-z]\{16\}\)}$/\1/')
    # Define the alphabets
    alphabet_upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    alphabet_lower="abcdefghijklmnopqrstuvwxyz"

    # Try all possible shifts (1 to 25)
    shift=1
    while [ $shift -le 25 ]; do
        # Create shifted alphabets
        shifted_upper=$(echo "$alphabet_upper$alphabet_upper" | cut -c$((27 - shift))-52)
        shifted_lower=$(echo "$alphabet_lower$alphabet_lower" | cut -c$((27 - shift))-52)
        # Decrypt prefix
        decrypted_prefix=$(echo "$encrypted_prefix" | tr "$alphabet_upper" "$shifted_upper")

        # Decrypt content
        decrypted_content=$(echo "$encrypted_content" | tr "$alphabet_lower" "$shifted_lower")
        decrypted_content=$(echo "$decrypted_content" | tr "$alphabet_upper" "$shifted_upper")
        if [ "$decrypted_prefix" = "NYCUNASA" ]; then
            answer="$decrypted_prefix{$decrypted_content}"
            break
        fi
        shift=$((shift + 1))
    done
        # If no valid decryption found
        if [ -z "$answer" ]; then
            answer="Invalid problem"
        fi
    fi
    response=$(curl -X POST -H "Content-Type: application/json" -d "{\"answer\": \"$answer\"}" "http://10.113.0.253/tasks/$task_id/submit")
    echo "Submission response: $response"
fi
