# IP & DNS Scanner

A Bash script to perform various network-related queries on a given IP address or DNS name. The script runs a series of commands to gather information such as WHOIS details, reverse DNS lookups, HTTP/HTTPS responses, and geolocation information using public APIs.

## Features

- **WHOIS Lookup**: Retrieves WHOIS information such as netname, description, country, and abuse contact.
- **Reverse DNS Lookup**: Performs a reverse DNS lookup for IP addresses to identify domain names.
- **HTTP/HTTPS Query**: Sends HTTP and HTTPS requests to determine the server's response code.
- **Geolocation**: Fetches geolocation information (city, region, country) based on the IP address.
- **Error Handling**: Graceful error handling for invalid input, network issues, or missing tools.

## Requirements

- Bash
- `jq` for parsing JSON output
- `whois` for WHOIS lookups
- `dig` (from `dnsutils`) for reverse DNS lookups
- `curl` for HTTP/HTTPS requests
- `ipinfo.io` for geolocation data

## Installation

1. Clone the repository:
    ```bash
git clone https://github.com/cyber272/IP_DNS_Scanner.git
    cd ip-dns-scanner
    ```

2. Make the script executable:
    ```bash
    chmod +x ip-scanner.sh
    ```

3. Install the required dependencies:
    ```bash
    sudo apt-get install whois dnsutils jq curl
    ```

## Usage

1. Run the script:
    ```bash
    ./ip-scanner.sh
    ```

2. Input an IP address or DNS name when prompted.

    Example:
    ```bash
    Enter the IP address or DNS: 8.8.8.8
    ```
   
## Sample Output
<img width="1437" alt="Screenshot 2024-10-21 at 14 55 37" src="https://github.com/user-attachments/assets/fadfa432-5550-4e9c-bb6f-a7780236631d">

## Error Handling

If the script detects any issues, such as missing tools or network issues, it will print an appropriate error message and exit.

Example error handling:
```bash
jq is not installed. Please install jq to continue.
```

## Customization

You can modify the script to include additional functionality like:

- Supporting IPv6
- Adding more detailed parsing of WHOIS data
- Using other geolocation APIs

## Contributing

Feel free to open issues or submit pull requests if you'd like to contribute or report a bug.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
