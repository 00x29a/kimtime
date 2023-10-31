#!/bin/bash

# Default config file
CONFIG_FILE="./.kimtime.conf"

# Parse command line options
while getopts a:p:c:g:h option
do
case "${option}"
in
a) ACTIVITY=${OPTARG};;
p) PROJECT=${OPTARG};;
c) CONFIG_FILE=${OPTARG};;
g) if [ ! -f $CONFIG_FILE ]; then
       echo "USERNAME=\"your_username\"" > $CONFIG_FILE
       echo "KIMAI_URL=\"https://your-kimai-url.com\"" >> $CONFIG_FILE
       echo "API_TOKEN=\"your_api_token\"" >> $CONFIG_FILE
       echo "Default config file $CONFIG_FILE has been created."
       echo "Please edit it with your actual username, Kimai URL, and API token."
       exit 0
   else
       echo "Config file $CONFIG_FILE already exists."
       exit 1
   fi;;
h) echo "Usage: $0 -a <activity> -p <project> [-c <config_file>] [-g <new_config_name>]"
   echo "Options:"
   echo "  -a <activity>    Specify the activity"
   echo "  -p <project>     Specify the project"
   echo "  -c <config_file> Specify the config file (default: config.cfg)"
   echo "  -g               Generate a default config file. Usage: -g <desired_config_name>"
   echo "  -h               Display this help message"
   exit 0;;
esac
done

# Load config file
source $CONFIG_FILE

# Check if activity and project are provided
if [ -z "$ACTIVITY" ] || [ -z "$PROJECT" ]; then
    echo "Usage: $0 -a <activity> -p <project> [-c <config_file>]"
    exit 1
fi

# Get the latest timesheet
TIMESHEET=$(curl -s -X GET -H "X-AUTH-USER: $USERNAME" -H "X-AUTH-TOKEN: $API_TOKEN" $KIMAI2_URL/api/timesheets)

# Extract the latest timesheet ID
TIMESHEET_ID=$(echo $TIMESHEET | jq -r '.[0].id')

# Get the details of the latest timesheet
TIMESHEET_DETAILS=$(curl -s -X GET -H "X-AUTH-USER: $USERNAME" -H "X-AUTH-TOKEN: $API_TOKEN" $KIMAI2_URL/api/timesheets/$TIMESHEET_ID)

# Check if clocked in
if echo "$TIMESHEET_DETAILS" | grep -q '"end":null'; then
    # Clock out
    CLOCK_OUT=$(curl -s -X PATCH -H "X-AUTH-USER: $USERNAME" -H "X-AUTH-TOKEN: $API_TOKEN" \
         -d "end=$(date +%Y-%m-%dT%H:%M:%S)" \
         $KIMAI2_URL/api/timesheets/$TIMESHEET_ID)
    END_TIME=$(echo $CLOCK_OUT | jq -r '.end')
    DURATION=$(echo $CLOCK_OUT | jq -r '.duration')
    echo "Clocked out at $END_TIME. Duration was $DURATION seconds."
elif echo "$TIMESHEET_DETAILS" | grep -q '"code":404,"message":"Not Found"'; then
    echo "No active timesheet found."
else
    # Clock in
    CLOCK_IN=$(curl -s -X POST -H "X-AUTH-USER: $USERNAME" -H "X-AUTH-TOKEN: $API_TOKEN" \
         -d "activity=$ACTIVITY&project=$PROJECT" \
         $KIMAI2_URL/api/timesheets)
    BEGIN_TIME=$(echo $CLOCK_IN | jq -r '.begin')
    echo "Clocked in at $BEGIN_TIME."
fi
