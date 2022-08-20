#!/bin/bash

TMP_STORE_LOCATION=/tmp/api_response.json

# getUserProjectID queries the github api for the specific project uuid
#   1: username
#   2: project id (number)
function getUserProjectID() {
    local USER=$1
    local PROJECT_NUMBER=$2
    gh api graphql -f query='
    query($user: String!, $number: Int!) {
      user(login: $user){
        projectV2(number: $number) {
          id
        }
      }
    }' -f user=$USER -F number=$PROJECT_NUMBER | jq .data.user.projectV2.id | sed -e 's+"++g'
}

# getUserProjectFields queries the github api for the specific project fields
#   1: project id (uuid)
function getUserProjectFields() {
    local PROJECT_ID=$1
    gh api graphql -f query='
      query($projectId: ID!){
      node(id: $projectId) {
        ... on ProjectV2 {
          fields(first: 100) {
            nodes {
              ... on ProjectV2Field {
                id
                name
              }
              ... on ProjectV2IterationField {
                id
                name
                configuration {
                  iterations {
                    startDate
                    id
                    title
                  }
                }
              }
              ... on ProjectV2SingleSelectField {
                id
                name
                options {
                  id
                  name
                }
              }
            }
          }
        }
      }
    }' -f projectId=$PROJECT_ID | jq .data.node.fields > $TMP_STORE_LOCATION
}

# extractUserFieldID returns the field id
#  1: field name
function extractUserFieldID() {
    local fieldName=$(echo $1 | sed -e "s+\"++g") # remove quotes
    jq -r ".nodes[] | select(.name == \"$fieldName\").id" $TMP_STORE_LOCATION
}

# extractUserFieldNodeIterationSettingValue returns the field node setting value id
#   1: field name
#   2: select value
#
# NOTE: If the value is @current or @next, we check the the array of iterations and return the current or next iteration id.
function extractUserFieldNodeIterationSettingValue() {
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

# extractUserFieldNodeSelectSettingValue returns the field node setting value id
#   1: field name
#   2: select value
function extractUserFieldNodeSelectSettingValue() {
    local fieldName=$(echo $1 | sed -e "s+\"++g") # remove quotes
    local selectValue=$(echo $2 | sed -e "s+\"++g") # remove quotes
    jq ".nodes[] | select(.name==\"Status\").options[] | select(.name==\"Done\").id" $TMP_STORE_LOCATION | sed -e "s+\"++g"
}
