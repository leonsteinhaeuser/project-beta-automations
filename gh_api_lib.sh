#!/bin/bash

TMP_STORE_LOCATION=/tmp/api_response.json

# getOrganizationProject queries the github api for the specific project
function getOrganizationProject() {
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

# extractOrganizationProjectID returns the project id
function extractOrganizationProjectID() {
    jq '.data.organization.projectNext.id' $TMP_STORE_LOCATION | sed -e "s+\"++g"
}

# extractOrganizationFieldID returns the field id
function extractOrganizationFieldID() {
    local fieldName=$1
    jq -r ".data.organization.projectNext.fields.nodes[] | select(.name== \"$fieldName\").id" $TMP_STORE_LOCATION
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







