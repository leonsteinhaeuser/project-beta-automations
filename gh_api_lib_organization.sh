#!/bin/bash

# getOrganizationProjectID queries the github api for the specific project uuid
#   1: organization (string)
#   2: project id (number)
function getOrganizationProjectID() {
    local ORGANIZATION=$1
    local PROJECT_NUMBER=$2
    gh api graphql --header 'GraphQL-Features: projects_next_graphql' -f query='
    query($org: String!, $number: Int!) {
      organization(login: $org){
        projectV2(number: $number) {
          id
        }
      }
    }' -f org=$ORGANIZATION -F number=$PROJECT_NUMBER | jq .data.organization.projectV2.id | sed -e 's+"++g'
}

# getOrganizationProjectFields queries the github api for the specific project fields
#   1: project id (uuid)
function getOrganizationProjectFields() {
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
