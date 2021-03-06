#!/bin/bash

TMP_STORE_LOCATION=/tmp/api_response.json

# getUserProject queries the github api for the specific project
#   1: username
#   2: project id (number)
function getUserProject() {
    local USER=$1
    local PROJECT_NUMBER=$2
    gh api graphql --header 'GraphQL-Features: projects_next_graphql' -f query='
    query($user: String!, $number: Int!) {
        user(login: $user){
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
    }' -f user=$USER -F number=$PROJECT_NUMBER > $TMP_STORE_LOCATION
}

# extractUserProjectID returns the project id
function extractUserProjectID() {
    jq '.data.user.projectNext.id' $TMP_STORE_LOCATION | sed -e "s+\"++g"
}

# extractUserFieldID returns the field id
#  1: field name
function extractUserFieldID() {
    local fieldName=$(echo $1 | sed -e "s+\"++g") # remove quotes
    jq -r ".data.user.projectNext.fields.nodes[] | select(.name == \"$fieldName\").id" $TMP_STORE_LOCATION
}

# extractUserFieldNodeIterationSettingValue returns the field node setting value id
#   1: field name
#   2: select value
function extractUserFieldNodeIterationSettingValue() {
    local fieldName=$(echo $1 | sed -e "s+\"++g") # remove quotes
    selectValue=$(echo $2 | sed -e "s+\"++g") # remove quotes
    jq ".data.user.projectNext.fields.nodes[] | select(.name == \"$fieldName\").settings | fromjson.configuration.iterations[] | select(.title==\"$selectValue\") |.id" $TMP_STORE_LOCATION | sed -e "s+\"++g"
}

# extractUserFieldNodeSelectSettingValue returns the field node setting value id
#   1: field name
#   2: select value
function extractUserFieldNodeSelectSettingValue() {
    local fieldName=$(echo $1 | sed -e "s+\"++g") # remove quotes
    selectValue=$(echo $2 | sed -e "s+\"++g") # remove quotes
    jq ".data.user.projectNext.fields.nodes[] | select(.name == \"$fieldName\").settings | fromjson.options[] | select(.name==\"$selectValue\") |.id" $TMP_STORE_LOCATION | sed -e "s+\"++g"
}
