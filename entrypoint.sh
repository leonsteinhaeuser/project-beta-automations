#!/bin/bash

organization_name=$1 # organization name
organization_project_id=$2 # organization id
resource_id=$3 # pr or issue node id
status_value=$4 # text representation of the card

# load lib bash functions
source gh_api_lib.sh

# request gh api and returns the project settings
getProject $organization_name $organization_project_id

PROJECT_ID=$(extractProjectID)
ITEM_ID=$(getItemID $PROJECT_ID $resource_id)

echo "PROJECT_ID: $PROJECT_ID"
echo "ITEM_ID: $ITEM_ID"

# Exit early without updating status if no status specified.
if [ -z "$status_value" ]; then
  exit 0
fi

STATUS_FIELD_ID=$(extractStatusFieldID)
# select field values
status_value_OPTION_ID=$(extractStatusFieldNodeSettingsByValue "$status_value")


echo "STATUS_FIELD_ID: $STATUS_FIELD_ID"
echo "status_value_OPTION_ID: $status_value_OPTION_ID"

# update single select field
updateSingleSelectField "$PROJECT_ID" "$ITEM_ID" "$STATUS_FIELD_ID" "$status_value_OPTION_ID"