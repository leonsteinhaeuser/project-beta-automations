#!/bin/bash

TMP_STORE_LOCATION=/tmp/api_response.json

# getProject queries the github api for the specific project
function getProject() {
    local ORGANIZATION=$1
    local PROJECT_NUMBER=$2
    gh api graphql --header 'GraphQL-Features: projects_next_graphql' -f query='
    query($org: String!, $number: Int!) {
        organization(login: $org){
            projectNext(number: $number) {
                id
                fields(first:20) {
                    nodes {
                        id
                        name
                        settings
                    }
                }
            }
        }
    }' -f org=$ORGANIZATION -F number=$PROJECT_NUMBER > $TMP_STORE_LOCATION
}

# extractProjectID returns the project id
function extractProjectID() {
    echo $(jq '.data.organization.projectNext.id' $TMP_STORE_LOCATION | sed -e "s+\"++g")
}

# extractStatusFieldID returns the status field id
function extractStatusFieldID() {
    echo $(jq '.data.organization.projectNext.fields.nodes[] | select(.name== "Status") | .id' $TMP_STORE_LOCATION | sed -e "s+\"++g")
}

# extractStatusFieldNodeSettingsByValue returns a list of available settings
function extractStatusFieldNodeSettingsByValue() {
    local STATUS_NAME=$1
    jq ".data.organization.projectNext.fields.nodes[] | select(.name== \"Status\") | .settings | fromjson.options[] | select(.name==\"$STATUS_NAME\") |.id" $TMP_STORE_LOCATION | sed -e "s+\"++g"
}

# getItemID queries the github api for the specific item_id
# Required arguments
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

function updateNonSingleSelectField() {
    local PROJECT_ID=$1
    local ITEM_ID=$2
    local FIELD_ID=$3
    local FIELD_VALUE$4
    echo $(gh api graphql --header 'GraphQL-Features: projects_next_graphql' -f query='
    mutation (
        $project: ID!
        $item: ID!
        $fieldid: ID!
        $fieldOption: String!
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
    }' -f project=$PROJECT_ID -f item=$ITEM_ID -f fieldid=$FIELD_ID -f fieldOption=$FIELD_VALUE | sed -e "s+\"++g")
}
