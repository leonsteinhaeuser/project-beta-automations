#!/bin/bash

local PROJECT_NAME=$1 # organization name
local ORGANIZATION_PROJECT_ID=$2 # organization id
local RESOURCE_ID=$3 # pr or issue id
local STATUS_VALUE=$status_value

# load lib bash functions
source project.sh

# request gh api and returns the project settings
getProject $PROJECT_NAME $ORGANIZATION_PROJECT_ID

PROJECT_ID=$(extractProjectID)

ITEM_ID=$(getItemID $PROJECT_ID $RESOURCE_ID)

STATUS_FIELD_ID=$(extractStatusFieldID)
# select field values
STATUS_VALUE_OPTION_ID=$(extractStatusFieldNodeSettingsByValue "$STATUS_VALUE")

echo "PROJECT_ID: $PROJECT_ID"
echo "ITEM_ID: $ITEM_ID"
echo "STATUS_FIELD_ID: $STATUS_FIELD_ID"

echo "STATUS_VALUE_OPTION_ID: $STATUS_VALUE_OPTION_ID"

# update single select field
updateSingleSelectField $PROJECT_ID $ITEM_ID $STATUS_FIELD_ID $STATUS_VALUE_OPTION_ID