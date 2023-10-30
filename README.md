# Kimai2 Time Tracking Script

This repository contains a shell script `kimtime.sh` for time tracking with Kimai2. The script uses the Kimai2 API to clock in and out of activities and projects.

## Usage

To run the script, use the following command:

```bash
./kimtime.sh -a "activity" -p "project" -c "kimtime.conf"
```

Replace "activity", "project", and "config.cfg" with the actual activity, project, and config file. The config file option is optional and defaults to "config.cfg".

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
