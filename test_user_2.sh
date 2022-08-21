#!/bin/bash

# global settings
ENTRYPOINT_MODE=user
ORG_OR_USER_NAME=leonsteinhaeuser
project_uuid=5
RESOURCE_NODE_ID=I_kwDOGWypss4-v6dh

source gh_api_lib_user.sh
source gh_api_global.sh
TMP_STORE_LOCATION=api_response.json

# query project
#getUserProject "$ORG_OR_USER_NAME" "$project_uuid"
echo "project response: "

##### project_uuid=$(getUserProjectID "$ORG_OR_USER_NAME" "$project_uuid")
echo "project_uuid: $project_uuid"
project_uuid=PVT_kwHOAoeKQc2PEQ

##### getUserProjectFields $project_uuid

echo "Current"
extractUserFieldNodeIterationSettingValue "Iteration" "@current"

echo "Next"
extractUserFieldNodeIterationSettingValue "Iteration" "@next"

echo "Select by title"
extractUserFieldNodeIterationSettingValue "Iteration" "Iteration 9"


# get PR or Issue global ID by resource node id
echo "Get Item ID"
issue_or_pr_item_uuid=$(getItemID "$project_uuid" "$RESOURCE_NODE_ID")
echo $issue_or_pr_item_uuid

# single select field value update (Status)


echo "Status Field UUID"
status_field_uuid=$(extractUserFieldID "Status")
echo $status_field_uuid

echo "Status done ID"
status_done_id=$(extractUserFieldNodeSelectSettingValue "Status" "Done")
echo $status_done_id

echo "Update status"
updateSingleSelectField "$project_uuid" "$issue_or_pr_item_uuid" "$status_field_uuid" "$status_done_id"

# single select field value update (Iteration)

echo "Iteration Field UUID"
iteration_field_uuid=$(extractUserFieldID "Iteration")
echo $iteration_field_uuid

echo "Iteration Current ID"
iteration_current_id=$(extractUserFieldNodeIterationSettingValue "Iteration" "@current")
echo $iteration_current_id

updateIterationField "$project_uuid" "$issue_or_pr_item_uuid" "$iteration_field_uuid" "$iteration_current_id"

# update text field value

echo "Text Field UUID"
text_field_uuid=$(extractUserFieldID "Severity")
echo $text_field_uuid

updateTextField "$project_uuid" "$issue_or_pr_item_uuid" "$text_field_uuid" "Low"