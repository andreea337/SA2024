#!/bin/sh

server_response='{"problem":"RCGYREWE{HdzBnrCnMjhExUaL}"}'

problem=$(echo "$server_response" | jq -r ".problem")
    echo "$problem"
    # Check if the problem matches the expected format
    if ! echo "$problem" | grep -Eq '^[A-Z]{8}\{[A-Za-z]{16}\}$'; then
        answer="Invalid problem"
    else
    # Extract the encrypted parts
    encrypted_prefix=$(echo "$problem" | cut -d'{' -f1)
    encrypted_content=$(echo "$problem" | sed 's/^[A-Z]\{8\}{\([A-Za-z]\{16\}\)}$/\1/')
    echo "encrypted prefix: $encrypted_prefix"
    echo "encrypted content: $encrypted_content"

    # Define the alphabets
    alphabet_upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    # alphabet_all="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    alphabet_lower="abcdefghijklmnopqrstuvwxyz"

    # Try all possible shifts (1 to 25)
    shift=1
    while [ $shift -le 25 ]; do
        # Create shifted alphabets
        shifted_upper=$(echo "$alphabet_upper$alphabet_upper" | cut -c$((27 - shift))-52)
        # shifted_all=$(echo "$alphabet_all$alphabet_all" | cut -c$((53 - shift))-104)
        shifted_lower=$(echo "$alphabet_lower$alphabet_lower" | cut -c$((27 - shift))-52)
        echo "$shifted_upper"
	echo "$shifted_lower"
        # Decrypt prefix
        decrypted_prefix=$(echo "$encrypted_prefix" | tr "$alphabet_upper" "$shifted_upper")
        
        # Decrypt content
        decrypted_content=$(echo "$encrypted_content" | tr "$alphabet_lower" "$shifted_lower")
        decrypted_content=$(echo "$decrypted_content" | tr "$alphabet_upper" "$shifted_upper")
        
        echo "Shift: $shift, Decrypted prefix: $decrypted_prefix, Decrypted content: $decrypted_content"
        
        if [ "$decrypted_prefix" = "NYCUNASA" ]; then
            answer="$decrypted_prefix{$decrypted_content}"
            echo "Answer found: $answer"
            break
        fi
        shift=$((shift + 1))
    done
        # If no valid decryption found
        if [ -z "$answer" ]; then
            answer="Invalid problem"
        fi

	echo "$answer"
    fi
