#!/bin/bash

# global settings
ENTRYPOINT_MODE=user
ORG_OR_USER_NAME=leonsteinhaeuser
PROJECT_ID=5
RESOURCE_NODE_ID=I_kwDOGWypss4-v6dh

ENTRYPOINT_SCRIPT=./entrypoint.sh

# change the status of a pr or issue
ENTRYPOINT_TYPE=status
RESOURCE_NODE_VALUE=Done
$ENTRYPOINT_SCRIPT "$ENTRYPOINT_MODE" "$ENTRYPOINT_TYPE" "$ORG_OR_USER_NAME" "$PROJECT_ID" "$RESOURCE_NODE_ID" "$RESOURCE_NODE_VALUE"

# change the status of a pr or issue to ''
$ENTRYPOINT_SCRIPT "$ENTRYPOINT_MODE" "$ENTRYPOINT_TYPE" "$ORG_OR_USER_NAME" "$PROJECT_ID" "$RESOURCE_NODE_ID"

# change the value of custom fields
date=$(date -d "+10 days" --rfc-3339=ns | sed 's/ /T/; s/\(\....\).*\([+-]\)/\1\2/g')
uuid1=$(uuidgen)
uuid2=$(uuidgen)
random_number=$(( $RANDOM % 2500 ))
custom_fields="[
    {
        \"name\": \"Priority\",
        \"type\": \"text\",
        \"value\": \"$uuid1\"
    },
    {
        \"name\": \"Number\",
        \"type\": \"number\",
        \"value\": \"$random_number\"
    },
    {
        \"name\": \"Date\",
        \"type\": \"date\",
        \"value\": \"$date\"
    },
    {
        \"name\": \"Single Select\",
        \"type\": \"single_select\",
        \"value\": \"Option 1\"
    },
    {
        \"name\": \"Iteration\",
        \"type\": \"iteration\",
        \"value\": \"Iteration 3\"
    }
]"

ENTRYPOINT_TYPE=custom_field
RESOURCE_NODE_VALUE=$custom_fields
$ENTRYPOINT_SCRIPT "$ENTRYPOINT_MODE" "$ENTRYPOINT_TYPE" "$ORG_OR_USER_NAME" "$PROJECT_ID" "$RESOURCE_NODE_ID" "$RESOURCE_NODE_VALUE"
