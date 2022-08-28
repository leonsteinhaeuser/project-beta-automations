#!/bin/bash

export DEBUG_COMMANDS="false"
export DEBUG_LOG="true"

# global settings
ENTRYPOINT_MODE=user
ORG_OR_USER_NAME=leonsteinhaeuser
PROJECT_ID=5
RESOURCE_NODE_ID=I_kwDOGWypss4-v6dh

ENTRYPOINT_SCRIPT=./entrypoint.sh

# change the status of a pr or issue
#ENTRYPOINT_TYPE=status
#RESOURCE_NODE_VALUE=Done
#$ENTRYPOINT_SCRIPT "$ENTRYPOINT_MODE" "$ENTRYPOINT_TYPE" "$ORG_OR_USER_NAME" "$PROJECT_ID" "$RESOURCE_NODE_ID" "$RESOURCE_NODE_VALUE"

# change the status of a pr or issue to ''
#echo "===== change status"
#$ENTRYPOINT_SCRIPT "$ENTRYPOINT_MODE" "$ENTRYPOINT_TYPE" "$ORG_OR_USER_NAME" "$PROJECT_ID" "$RESOURCE_NODE_ID"

# change the value of custom fields
date=$(date +"%Y-%m-%d")
uuid1=$(uuidgen)
uuid2=$(uuidgen)
random_number=$(( $RANDOM % 10 )).$(( $RANDOM % 10 ))

custom_fields="[
    {
        \"name\": \"Single Select\",
        \"type\": \"single_select\",
        \"value\": \"Option 2\"
    },
    {
        \"name\": \"Priority\",
        \"type\": \"text\",
        \"value\": \"$uuid1\"
    },
    {
        \"name\": \"Iteration\",
        \"type\": \"iteration\",
        \"value\": \"Iteration 10\"
    },
    {
        \"name\": \"Iteration\",
        \"type\": \"iteration\",
        \"value\": \"@current\"
    },
    {
        \"name\": \"Iteration\",
        \"type\": \"iteration\",
        \"value\": \"@next\"
    },
    {
        \"name\": \"Date\",
        \"type\": \"date\",
        \"value\": \"$date\"
    },
    {
        \"name\": \"Number\",
        \"type\": \"number\",
        \"value\": \"$random_number\"
    }
]"

echo "===== change custom fields"
ENTRYPOINT_TYPE=custom_field
RESOURCE_NODE_VALUE=$custom_fields
$ENTRYPOINT_SCRIPT "$ENTRYPOINT_MODE" "$ENTRYPOINT_TYPE" "$ORG_OR_USER_NAME" "$PROJECT_ID" "$RESOURCE_NODE_ID" "$RESOURCE_NODE_VALUE"


custom_fields="[
    {
        \"name\": \"Iteration\",
        \"type\": \"iteration\",
        \"value\": \"@next\"
    }
]"
RESOURCE_NODE_VALUE=$custom_fields
$ENTRYPOINT_SCRIPT "$ENTRYPOINT_MODE" "$ENTRYPOINT_TYPE" "$ORG_OR_USER_NAME" "$PROJECT_ID" "$RESOURCE_NODE_ID" "$RESOURCE_NODE_VALUE"

custom_fields="[
    {
        \"name\": \"Iteration\",
        \"type\": \"iteration\",
        \"value\": \"@current\"
    }
]"
RESOURCE_NODE_VALUE=$custom_fields
$ENTRYPOINT_SCRIPT "$ENTRYPOINT_MODE" "$ENTRYPOINT_TYPE" "$ORG_OR_USER_NAME" "$PROJECT_ID" "$RESOURCE_NODE_ID" "$RESOURCE_NODE_VALUE"