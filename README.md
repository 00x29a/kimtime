# Kimai2 Time Tracking Script

This repository contains a shell script `kimtime.sh` for time tracking with Kimai2. The script uses the Kimai2 API to clock in and out of activities and projects.

## Usage

To run the script, use the following command:

```bash
./kimtime.sh -a "activity" -p "project" -c "kimtime.conf"
```

Replace "activity", "project", and "config.cfg" with the actual activity, project, and config file. The config file option is optional and defaults to "config.cfg".

## Requirements

This script requires the following:

1. **Bash shell**: The script is written in Bash. Most Linux distributions come with Bash preinstalled.

2. **cURL**: The script uses cURL to send HTTP requests. You can install cURL with the package manager for your Linux distribution. For example, on Ubuntu, you can install cURL with `sudo apt install curl`.

3. **jq**: The script uses jq to parse JSON responses. You can install jq with the package manager for your Linux distribution. For example, on Ubuntu, you can install jq with `sudo apt install jq`.

4. **Kimai2 API**: The script interacts with the Kimai2 API. You need to have access to a Kimai2 instance and an API token.

5. **Config file**: The script reads the username, Kimai2 URL, and API token from a config file. You need to create this config file and provide the correct values.

## Configuration

The script reads the username, Kimai2 URL, and API token from a config file. Here's what the config file would look like:

```bash
USERNAME="your_username"
KIMAI2_URL="https://your-kimai2-url.com"
API_TOKEN="your_api_token"
```

Replace "your_username", "https://your-kimai2-url.com", and "your_api_token" with your actual username, Kimai2 URL, and API token.

## Clock In/Out Status

The script sends a GET request to the Kimai2 API to get the latest timesheet and its details. It checks if the "end" field in the response is null, which indicates that you're currently clocked in. If you're clocked in, it clocks you out. If you're not clocked in, it clocks you in.

If the response from the Kimai2 API contains the message '{"code":404,"message":"Not Found"}', it prints a message and does not attempt to clock in.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
