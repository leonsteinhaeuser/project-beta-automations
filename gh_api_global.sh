#!/bin/bash

# getItemID queries the github api for the specific item_id
# Required arguments:
#   1: project id
#   2: resource node id
function getItemID() {
    local project_id=$1
    local resource_id=$2
    gh api graphql -f query='
    mutation($project:ID!, $pr:ID!) {
        addProjectV2ItemById(input: {projectId: $project, contentId: $pr}) {
            item {
                id
            }
        }
    }' -f project=$project_id -f pr=$resource_id --jq '.data.addProjectV2ItemById.item.id'
}

# extractFieldID returns the field uuid
#  1: field name (string)
function extractFieldID() {
    local fieldName=$(echo $1 | sed -e "s+\"++g") # remove quotes
    jq -r ".nodes[] | select(.name == \"$fieldName\").id" $TMP_STORE_LOCATION
}

# extractFieldNodeSingleSelectSettingValue returns the field node setting value id
#   1: field name (string)
#   2: select value (string)
function extractFieldNodeSingleSelectSettingValue() {
    local fieldName=$(echo $1 | sed -e "s+\"++g") # remove quotes
    local selectValue=$(echo $2 | sed -e "s+\"++g") # remove quotes
    jq ".nodes[] | select(.name==\"$fieldName\").options[] | select(.name==\"$selectValue\").id" $TMP_STORE_LOCATION | sed -e "s+\"++g"
}

# extractFieldNodeIterationSettingValue returns the field node setting value id
#   1: field name (string)
#   2: select value (string)
#
# NOTE: If the value is @current or @next, we check the the array of iterations and return the current or next iteration id.
function extractFieldNodeIterationSettingValue() {
    local field_name=$(echo $1 | sed -e "s+\"++g") # remove quotes
    local select_value=$(echo $2 | sed -e "s+\"++g") # remove quotes

    iterations_for_field=$(jq ".nodes[] | select(.name==\"$field_name\").configuration.iterations" $TMP_STORE_LOCATION)
    dates=$(echo $iterations_for_field | jq -r '.[] | .startDate' | sort)
    STRINGTEST=(${dates[@]})
    if [ "$select_value" == "@current" ]; then
        CURRENT_ITERATION=${STRINGTEST[0]}
        echo -e $iterations_for_field | jq -r '.[] | select(.startDate == "'$CURRENT_ITERATION'").id'
    elif [ "$select_value" == "@next" ]; then
        NEXT_ITERATION=${STRINGTEST[1]}
        echo -e $iterations_for_field | jq -r '.[] | select(.startDate == "'$NEXT_ITERATION'").id'
    else
        echo -e $iterations_for_field | jq -r ".[] | select(.title==\"$select_value\") | .id"
    fi
}

# updateSingleSelectField updates the given item field with the defined value
# Required arguments:
#   1: project id
#   2: project item id
#   3: field id
#   4: field option string (id as string)
function updateSingleSelectField() {
    local project_id=$1
    local item_id=$2
    local field_id=$3
    local field_option=$4

    gh api graphql -f query='
    mutation (
        $project: ID!
        $item: ID!
        $fieldid: ID!
        $fieldOption: String!
    ) {
        updateProjectV2ItemFieldValue(
            input: {
                projectId: $project
                itemId: $item
                fieldId: $fieldid
                value: {
                    singleSelectOptionId: $fieldOption
                }
            }
        )
        {
            projectV2Item {
                id
            }
        }
    }' -f project=$project_id -f item=$item_id -f fieldid=$field_id -f fieldOption=$field_option | sed -e "s+\"++g"
}

# updateIterationField updates the given item field with the defined value
# Required arguments:
#   1: project id
#   2: project item id
#   3: field id
#   4: field option string (id as string)
function updateIterationField() {
    local project_id=$1
    local item_id=$2
    local field_id=$3
    local field_option=$4

    gh api graphql --header 'GraphQL-Features: projects_next_graphql' -f query='
    mutation (
        $project: ID!
        $item: ID!
        $fieldid: ID!
        $fieldOption: String!
    ) {
        set_status: updateProjectV2ItemFieldValue(
            input: {
                projectId: $project
                itemId: $item
                fieldId: $fieldid
                value: {
                    iterationId: $fieldOption
                }
            }
        )
        {
            projectV2Item {
                id
            }
        }
    }' -f project=$project_id -f item=$item_id -f fieldid=$field_id -f fieldOption=$field_option | sed -e "s+\"++g"
}

# updateTextField updates the given item field with the defined value
# Required arguments:
#   1: project id
#   2: project item id
#   3: field id
#   4: field value
function updateTextField() {
    local PROJECT_ID=$1
    local ITEM_ID=$2
    local FIELD_ID=$3
    local FIELD_VALUE=$4
    gh api graphql -f query='
    mutation (
        $project: ID!
        $item: ID!
        $fieldid: ID!
        $fieldValue: String!
    ) {
        updateProjectV2ItemFieldValue(
            input: {
                projectId: $project
                itemId: $item
                fieldId: $fieldid
                value: {
                    text: $fieldValue
                }
            }
        ) {
            projectV2Item {
                id
            }
        }
    }' -f project=$PROJECT_ID -f item=$ITEM_ID -f fieldid=$FIELD_ID -f fieldValue="$FIELD_VALUE" | sed -e "s+\"++g"
}

# updateNumberField updates the given item field with the defined value
# Required arguments:
#   1: project id
#   2: project item id
#   3: field id
#   4: field value
function updateNumberField() {
    local PROJECT_ID=$1
    local ITEM_ID=$2
    local FIELD_ID=$3
    local FIELD_VALUE=$4
    gh api graphql -f query="
    mutation (
        \$project: ID!
        \$item: ID!
        \$fieldid: ID!
    ) {
        updateProjectV2ItemFieldValue(
            input: {
                projectId: \$project
                itemId: \$item
                fieldId: \$fieldid
                value: {
                    number: $FIELD_VALUE
                }
            }
        ) {
            projectV2Item {
                id
            }
        }
    }" -f project=$PROJECT_ID -f item=$ITEM_ID -f fieldid=$FIELD_ID | sed -e "s+\"++g"
}

# updateDateField updates the given item field with the defined value
# Required arguments:
#   1: project id
#   2: project item id
#   3: field id
#   4: field value
function updateDateField() {
    local PROJECT_ID=$1
    local ITEM_ID=$2
    local FIELD_ID=$3
    local FIELD_VALUE=$4
    gh api graphql -f query='
    mutation (
        $project: ID!
        $item: ID!
        $fieldid: ID!
        $fieldValue: Date!
    ) {
        updateProjectV2ItemFieldValue(
            input: {
                projectId: $project
                itemId: $item
                fieldId: $fieldid
                value: {
                    date: $fieldValue
                }
            }
        ) {
            projectV2Item {
                id
            }
        }
    }' -f project=$PROJECT_ID -f item=$ITEM_ID -f fieldid=$FIELD_ID -f fieldValue="$FIELD_VALUE" | sed -e "s+\"++g"
}