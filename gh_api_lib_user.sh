#!/bin/bash

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

