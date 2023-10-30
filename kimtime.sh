#!/bin/bash

# Default config file
CONFIG_FILE="config.cfg"

# Parse command line options
while getopts a:p:c:h option
do
case "${option}"
in
a) ACTIVITY=${OPTARG};;
p) PROJECT=${OPTARG};;
c) CONFIG_FILE=${OPTARG};;
h) echo "Usage: $0 -a <activity> -p <project> [-c <config_file>]"
   echo "Options:"
   echo "  -a <activity>    Specify the activity"
   echo "  -p <project>     Specify the project"
   echo "  -c <config_file> Specify the config file (default: config.cfg)"
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
