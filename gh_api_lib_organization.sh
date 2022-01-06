#!/bin/bash

TMP_STORE_LOCATION=/tmp/api_response.json

# getOrganizationProject queries the github api for the specific project
#   1: organization
#   2: project id (number)
function getOrganizationProject() {
    local ORGANIZATION=$1
    local PROJECT_NUMBER=$2
    gh api graphql --header 'GraphQL-Features: projects_next_graphql' -f query='
    query($organization: String!, $number: Int!) {
        organization(login: $organization){
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
    }' -f organization=$ORGANIZATION -F number=$PROJECT_NUMBER > $TMP_STORE_LOCATION
}

# extractOrganizationProjectID returns the project id
function extractOrganizationProjectID() {
    jq '.data.organization.projectNext.id' $TMP_STORE_LOCATION | sed -e "s+\"++g"
}

# extractOrganizationFieldID returns the field id
#  1: field name
function extractOrganizationFieldID() {
    local fieldName=$(echo $1 | sed -e "s+\"++g") # remove quotes
    jq -r ".data.organization.projectNext.fields.nodes[] | select(.name == \"$fieldName\").id" $TMP_STORE_LOCATION
}

# extractOrganizationFieldNodeIterationSettingValue returns the field node setting value id
#   1: field name
#   2: select value
function extractOrganizationFieldNodeIterationSettingValue() {
    local fieldName=$(echo $1 | sed -e "s+\"++g") # remove quotes
    selectValue=$(echo $2 | sed -e "s+\"++g") # remove quotes
    jq ".data.organization.projectNext.fields.nodes[] | select(.name == \"$fieldName\").settings | fromjson.configuration.iterations[] | select(.title==\"$selectValue\") |.id" $TMP_STORE_LOCATION | sed -e "s+\"++g"
}

# extractOrganizationFieldNodeSelectSettingValue returns the field node setting value id
#   1: field name
#   2: select value
function extractOrganizationFieldNodeSelectSettingValue() {
    local fieldName=$(echo $1 | sed -e "s+\"++g") # remove quotes
    selectValue=$(echo $2 | sed -e "s+\"++g") # remove quotes
    jq ".data.organization.projectNext.fields.nodes[] | select(.name == \"$fieldName\").settings | fromjson.options[] | select(.name==\"$selectValue\") |.id" $TMP_STORE_LOCATION | sed -e "s+\"++g"
}
