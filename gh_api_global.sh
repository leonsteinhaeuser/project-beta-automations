#!/bin/bash

# getItemID queries the github api for the specific item_id
# Required arguments:
#   1: project id
#   2: resource node id
function getItemID() {
    local project_id=$1
    local resource_id=$2
    gh api graphql --header 'GraphQL-Features: projects_next_graphql' -f query='
    mutation($project:ID!, $resource_id:ID!) {
        addProjectNextItem(input: {projectId: $project, contentId: $resource_id}) {
            projectNextItem {
                id
            }
        }
    }' -f project=$project_id -f resource_id=$resource_id --jq '.data.addProjectNextItem.projectNextItem.id' | sed -e "s+\"++g"
}

# updateSingleSelectField updates the given item field with the defined value
# Required arguments:
#   1: project id
#   2: project item id
#   3: field id
#   4: field option id
function updateSingleSelectField() {
    local project_id=$1
    local item_id=$2
    local field_id=$3
    local field_option=$4
    echo $(gh api graphql --header 'GraphQL-Features: projects_next_graphql' -f query='
    mutation (
        $project: ID!
        $item: ID!
        $fieldid: ID!
        $fieldOption: ID!
    ) {
        updateProjectNextItemField(
            input: {
                projectId: $project
                itemId: $item
                fieldId: $fieldid
                value: $fieldOption
            }
        )
        {
            projectNextItem {
                id
            }
        }
    }' -f project=$project_id -f item=$item_id -f fieldid=$field_id -f fieldOption=$field_option | sed -e "s+\"++g")
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
    echo $(gh api graphql --header 'GraphQL-Features: projects_next_graphql' -f query='
    mutation (
        $project: ID!
        $item: ID!
        $fieldid: ID!
        $fieldValue: String!
    ) {
        updateProjectNextItemField(
            input: {
                projectId: $project
                itemId: $item
                fieldId: $fieldid
                value: $fieldValue
            }
        )
        {
            projectNextItem {
                id
            }
        }
    }' -f project=$PROJECT_ID -f item=$ITEM_ID -f fieldid=$FIELD_ID -f fieldValue="$FIELD_VALUE" | sed -e "s+\"++g")
}
