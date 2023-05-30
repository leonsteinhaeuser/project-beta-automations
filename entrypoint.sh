#!/bin/bash

set -e

if [ "$DEBUG_COMMANDS" = "true" ]; then
    set -x
fi

# DEBUG_MODE_ENABLED provides a way to enable the debug mode
# export DEBUG_MODE=true
DEBUG_MODE_ENABLED="${DEBUG_MODE:-false}"

# MOVE_RELATED_ISSUES provides a way to enable the move related issues
# This will move all related issues to the same column as the pull request
MOVE_RELATED_ISSUES="${MOVE_RELATED_ISSUES:-false}"

# ENTRYPOINT_MODE described the mode this application should run with
# supported ENTRYPOINT_MODEs are:
#   - organization
#   - user
ENTRYPOINT_MODE=$1
# ENTRYPOINT_TYPE describes the type of the resource
# supported ENTRYPOINT_TYPEs are:
#   - status
#   - custom_field
ENTRYPOINT_TYPE=$2
# ORG_OR_USER_NAME describes the ORG_OR_USER_NAME of the organisation or user
ORG_OR_USER_NAME=$3
# PROJECT_ID describes the project id of the organisation or user
PROJECT_ID=$4
# RESOURCE_NODE_ID describes the resource id of the resource
# this is the node id of the resource
# e.g. pr or issue node id
RESOURCE_NODE_ID=$5
# RESOURCE_NODE_VALUE describes the value of the resource
# if ENTRYPOINT_TYPE is set to 'custom_field' this field expects json value for the custom fields
# structure:
# [
#   {
#      "name": "Priority",  # name of the custom field
#      "type": "text",      # type of the custom field. Can be one of: text, number, date, single_select, iteration
#      "value": "uuid1"     # value of the custom field
#   }
# ]
# ATTENTION: make sure that the json value is sent as escaped string
RESOURCE_NODE_VALUE=$6

# check if values are set

if [ -z "$ENTRYPOINT_MODE" ]; then
    echo "Parameter 1: ENTRYPOINT_MODE is not set"
    exit 1
fi
if [ -z "$ENTRYPOINT_TYPE" ]; then
    echo "Parameter 2: ENTRYPOINT_TYPE is not set"
    exit 1
fi
if [ -z "$ORG_OR_USER_NAME" ]; then
    echo "Parameter 3: ORG_OR_USER_NAME is not set"
    exit 1
fi
if [ -z "$PROJECT_ID" ]; then
    echo "Parameter 4: PROJECT_ID is not set"
    exit 1
fi
if [ -z "$RESOURCE_NODE_ID" ]; then
    echo "Parameter 5: RESOURCE_NODE_ID is not set"
    exit 1
fi
if [ "$ENTRYPOINT_TYPE" == "custom_field" ] && [ -z "$RESOURCE_NODE_VALUE" ]; then
    echo "Parameter 6: ENTRYPOINT_TYPE=\"custom_field\" has beend specified but RESOURCE_NODE_VALUE is not set"
    exit 1
fi

#######################################################################################################
#######################################################################################################
#######################################################################################################
#######################################################################################################
#######################################################################################################

export TMP_STORE_LOCATION="/tmp/api_${ENTRYPOINT_MODE}_response.json"

# load the api libs
source gh_api_lib_user.sh
source gh_api_lib_organization.sh
source gh_api_global.sh

# define a few variables that are shared between different functions
PROJECT_UUID=""
PROJECT_ITEM_UUID=""

# stores the log output the script produces
log=""


function updateFieldScope() {
    case "$ENTRYPOINT_TYPE" in
        status)
            STATUS_FIELD_ID=$(extractFieldID "Status")
            STATUS_FIELD_VALUE_ID=$(extractFieldNodeSingleSelectSettingValue "Status" "$RESOURCE_NODE_VALUE")
            response=$(updateSingleSelectField "$PROJECT_UUID" "$PROJECT_ITEM_UUID" "$STATUS_FIELD_ID" "$STATUS_FIELD_VALUE_ID")
            log="$log\n$response"

            if [ "$MOVE_RELATED_ISSUES" = "true" ]; then
                prdata=$(getPullRequestByNodeID $RESOURCE_NODE_ID)
                PR_REPO_ISSUE_NUMBER=$(echo $prdata | jq .data.node.number)
                PR_REPO_NAME=$(echo $prdata | jq .data.node.repository.name | sed -e 's+"++g')
                PR_REPO_OWNER=$(echo $prdata | jq .data.node.repository.owner.login | sed -e 's+"++g')

                # get linked issue ids
                linked_issue_ids=$(getRelatedPullRequestIssueIDs $PR_REPO_OWNER $PR_REPO_NAME $PR_REPO_ISSUE_NUMBER)
                for issue_id in $linked_issue_ids; do
                    project_item_id=$(getItemID $PROJECT_UUID $issue_id)
                    response=$(updateSingleSelectField "$PROJECT_UUID" "$project_item_id" "$STATUS_FIELD_ID" "$STATUS_FIELD_VALUE_ID")
                    log="$log\nUpdating referenced issue id: [ $issue_id ]\n$response"
                done
            fi
            ;;
        custom_field)
            x=0 # counter
            while true; do
                nameField=$(echo $RESOURCE_NODE_VALUE | jq ".[$x].name")
                typeField=$(echo $RESOURCE_NODE_VALUE | jq ".[$x].type" | sed 's/\"//g')
                valueField=$(echo $RESOURCE_NODE_VALUE | jq ".[$x].value")
                if [ "$nameField" == "null" ] || [ "$valueField" == "null" ]; then
                    # no more custom fields
                    break
                else
                    local fieldID=$(extractFieldID "$nameField")
                    log="$log\n\n$nameField: $fieldID"
                    case $typeField in
                        'text')
                            valueFieldWithoutQuotes=$(echo $valueField | sed 's/\"//g')
                            log="$log\nUpdating text field: $nameField with value: $valueFieldWithoutQuotes"
                            response=$(updateTextField "$PROJECT_UUID" "$PROJECT_ITEM_UUID" $fieldID "$valueFieldWithoutQuotes")
                            log="$log\n$response\n"
                            ;;
                        "number")
                            valueFieldWithoutQuotes=$(echo $valueField | sed 's/\"//g')
                            log="$log\nUpdating number field: $nameField with value: $valueFieldWithoutQuotes"
                            response=$(updateNumberField "$PROJECT_UUID" "$PROJECT_ITEM_UUID" $fieldID "$valueFieldWithoutQuotes")
                            log="$log\n$response\n"
                            ;;
                        "date")
                            valueFieldWithoutQuotes=$(echo $valueField | sed 's/\"//g')
                            log="$log\nUpdating date field: $nameField with value: $valueFieldWithoutQuotes"
                            response=$(updateDateField "$PROJECT_UUID" "$PROJECT_ITEM_UUID" $fieldID "$valueFieldWithoutQuotes")
                            log="$log\n$response\n"
                            ;;
                        "single_select")
                            log="$log\nUpdating single select field: $nameField with value: $valueField"
                            selectedOption=$(extractFieldNodeSingleSelectSettingValue "$nameField" "$valueField")
                            response=$(updateSingleSelectField "$PROJECT_UUID" "$PROJECT_ITEM_UUID" "$fieldID" "$selectedOption")
                            log="$log\n$response\n"
                            ;;
                        "iteration")
                            log="$log\nUpdating iteration field: $nameField with value: $valueField"
                            iterationFieldNodeID=$(extractFieldNodeIterationSettingValue "$nameField" "$valueField")
                            response=$(updateIterationField "$PROJECT_UUID" "$PROJECT_ITEM_UUID" "$fieldID" "$iterationFieldNodeID")
                            log="$log\n$response\n"
                            ;;
                        *)
                            echo "Unknown field type: $typeField"
                            exit -1
                            ;;
                    esac
                fi
                x=$(( $x + 1 ))
            done
            ;;
        *)
            echo "Unknown ENTRYPOINT_TYPE: $ENTRYPOINT_TYPE"
            exit 2
            ;;
    esac
}

# main entrypoint for the application
case "$ENTRYPOINT_MODE" in
    organization)
        PROJECT_UUID=$(getOrganizationProjectID "$ORG_OR_USER_NAME" "$PROJECT_ID")
        echo "PROJECT_UUID: $PROJECT_UUID"
        getOrganizationProjectFields "$PROJECT_UUID"
        PROJECT_ITEM_UUID=$(getItemID $PROJECT_UUID $RESOURCE_NODE_ID)

        updateFieldScope
        ;;
    user)
        PROJECT_UUID=$(getUserProjectID "$ORG_OR_USER_NAME" "$PROJECT_ID")
        echo "PROJECT_UUID: $PROJECT_UUID"
        getUserProjectFields "$PROJECT_UUID"
        PROJECT_ITEM_UUID=$(getItemID $PROJECT_UUID $RESOURCE_NODE_ID)

        updateFieldScope
        ;;
    *)
        echo "ENTRYPOINT_MODE $ENTRYPOINT_MODE is not supported"
        exit 1
        ;;
esac

if [ "$DEBUG_LOG" == "true" ]; then
    echo "==========================   Debug mode is ON =========================="
    echo "PROJECT_UUID: $PROJECT_UUID"
    echo "PROJECT_ITEM_UUID: $PROJECT_ITEM_UUID"
    echo -e "log:\n$log"
    echo "==========================   Debug mode is ON =========================="
fi