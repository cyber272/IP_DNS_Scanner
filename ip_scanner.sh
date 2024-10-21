#!/bin/bash

# Check if jq is installed
command -v jq >/dev/null 2>&1 || { echo "jq is not installed. Please install jq to continue." >&2; exit 1; }

# Check if whois is installed
command -v whois >/dev/null 2>&1 || { echo "whois is not installed. Please install whois to continue." >&2; exit 1; }

# Function to validate the IP address or DNS name format
validate_input() {
    local input=$1

    # Check if the input is a valid IP address or a DNS name
    if [[ $input =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        # Validate the IP address octets
        IFS='.' read -r -a octets <<< "$input"
        for octet in "${octets[@]}"; do
            if ((octet < 0 || octet > 255)); then
                return 1  # Invalid IP address
            fi
        done
        return 0  # Valid IP address
    elif [[ $input =~ ^[a-zA-Z0-9.-]+$ ]]; then
        return 0  # Valid DNS name
    else
        return 1  # Invalid format
    fi
}

# Function to check if a command ran successfully
check_success() {
    if [ $? -ne 0 ]; then
        echo "An error occurred while executing the last command. Exiting."
        exit 1
    fi
}

# Prompt the user for input until a valid IP address or DNS name is entered
while true; do
    read -p "Enter the IP address or DNS: " input_address
    if validate_input "$input_address"; then
        break  # Exit the loop if the input is valid
    else
        echo "Invalid input format. Please enter a valid IPv4 address or DNS name."
    fi
done

# Perform WHOIS Lookup
echo "Performing WHOIS Lookup..."
whois_output=$(whois "$input_address" 2>/dev/null)

# Error handling for WHOIS command
if [ $? -ne 0 ]; then
    echo "Failed to fetch WHOIS information. The server may not be responding or WHOIS may be unavailable."
    exit 1  # Exit if the WHOIS query fails
fi

# Extracting fields from WHOIS output
netname=$(echo "$whois_output" | grep -i 'Netname:' | awk '{print $2}' | sed 's/^Netname: //I')
descr=$(echo "$whois_output" | grep -i 'Descr:' | awk '{$1=""; print $0}' | sed 's/^ //')
country=$(echo "$whois_output" | grep -i 'Country:' | awk 'NR==1 {print $2}')  # Take only the first occurrence
role=$(echo "$whois_output" | grep -i 'Role:' | awk '{$1=""; print $0}' | sed 's/^ //')
abuse_mailbox=$(echo "$whois_output" | grep -i 'Abuse-mailbox:' | awk '{print $2}')


# Display WHOIS results
echo "======================="
echo "IP Information"
echo "--------------"
echo "Netname: ${netname:-Not available}"
echo "Description: ${descr:-Not available}"
echo "Country: ${country:-Not available}"
echo "Role: ${role:-Not available}"
echo "Abuse Mailbox: ${abuse_mailbox:-Not available}"
echo ""

# Reverse DNS Lookup using dig
echo "Performing Reverse DNS Lookup..."

# Check if the input is an IP address (for reverse lookup)
if [[ $input_address =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    reverse_dns=$(dig -x "$input_address" +short 2>/dev/null)
    check_success
else
    echo "Using DNS name for reverse lookup..."
    reverse_dns=$(dig "$input_address" +short 2>/dev/null)
fi

echo "======================="
echo "Reverse DNS Information"
echo "-----------------------"
if [ -z "$reverse_dns" ]; then
    echo "No reverse DNS records found."
else
    echo "Domain name(s): $reverse_dns"
fi
echo ""

# HTTP Query with timeout and retries
echo "Performing HTTP Query..."
http_response=$(curl -A "User-Agent: MyIPScanner/1.0" -o /dev/null -s -w "%{http_code}\n" --max-time 5 --retry 2 --retry-connrefused "http://$input_address")
if [ $? -ne 0 ]; then
    echo "An error occurred while performing the HTTP query. The server may not be responding."
    http_response="000"
fi

echo "======================="
echo "HTTP Query Information"
echo "----------------------"
if [ "$http_response" == "000" ]; then
    echo "No HTTP response. The server might not be running on HTTP."
else
    echo "HTTP Response Code: $http_response"
fi
echo ""

# HTTPS Query with timeout and retries
echo "Performing HTTPS Query..."
https_response=$(curl -A "User-Agent: MyIPScanner/1.0" -o /dev/null -s -w "%{http_code}\n" --max-time 5 --retry 2 --retry-connrefused -k "https://$input_address")
if [ $? -ne 0 ]; then
    echo "An error occurred while performing the HTTPS query. The server may not be responding."
    https_response="000"
fi

echo "======================="
echo "HTTPS Query Information"
echo "-----------------------"
if [ "$https_response" == "000" ]; then
    echo "No HTTPS response. The server might not be running on HTTPS."
else
    echo "HTTPS Response Code: $https_response"
fi
echo ""

# Geolocation Lookup using ipinfo.io API with jq for parsing
echo "Fetching Geolocation Information..."
geo_info=$(curl -s "http://ipinfo.io/$input_address/json" --max-time 5)

# Check if curl executed successfully, otherwise handle the error
if [ $? -ne 0 ]; then
    echo "Failed to fetch geolocation information. The server may not be responding."
    exit 1  # Exit if the geolocation fetch fails
fi

# Check if the geolocation data is not empty before parsing
if [ -n "$geo_info" ]; then
    # Parse the response using jq, with fallbacks if fields are missing
    city=$(echo "$geo_info" | jq -r '.city // "Not available"' 2>/dev/null || echo "Not available")
    region=$(echo "$geo_info" | jq -r '.region // "Not available"' 2>/dev/null || echo "Not available")
    country=$(echo "$geo_info" | jq -r '.country // "Not available"' 2>/dev/null || echo "Not available")
else
    city="Not available"
    region="Not available"
    country="Not available"
fi


# Display geolocation info
echo "======================="
echo "Geolocation Information"
echo "-----------------------"
echo "City: $city"
echo "Region: $region"
echo "Country: $country"
echo ""
