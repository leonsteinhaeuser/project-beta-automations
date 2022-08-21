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
