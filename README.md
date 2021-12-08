# project-beta-automations

This repository provides the ability to automate GitHub issues and pull requests for [Github Projects (Beta)](https://docs.github.com/en/issues/trying-out-the-new-projects-experience/about-projects). To do this, it automates the **Status** field to put issues and pull requests in the desired status, and therefore the desired column in the Board view. If the issue or pull request is not already in the Project, it will be added.

## Example workflow within your repository

Note: GITHUB_TOKEN does not have the necessary scopes to access projects (beta).
You must create a token with ***org:write*** scope and save it as a secret in your repository or organization.
In the following workflow, replace ***YOUR_TOKEN*** with the name of the secret. For more information, see [Creating a personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).

Organization based:

```yaml
name: Project automations
on:
  issues:
    types:
      - opened
      - reopened
      - closed
  pull_request:
    types:
      - opened
      - ready_for_review
      - reopened
      - review_requested
      - closed
jobs:
  issue_opened_and_reopened:
    name: issue_opened_and_reopened
    runs-on: ubuntu-latest
    if: github.event_name == 'issues' && (github.event.action == 'opened' || github.event.action == 'reopened')
    steps:
      - name: 'Move issue to "Todo"'
        uses: leonsteinhaeuser/project-beta-automations@v1.0.2
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          organization: sample-org
          project_id: 1
          resource_node_id: ${{ github.event.issue.node_id }}
          status_value: "Todo"
  issue_closed:
    name: issue_closed
    runs-on: ubuntu-latest
    if: github.event_name == 'issues' && github.event.action == 'closed'
    steps:
      - name: 'Moved issue to "Done"'
        uses: leonsteinhaeuser/project-beta-automations@v1.0.2
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          organization: sample-org
          project_id: 1
          resource_node_id: ${{ github.event.issue.node_id }}
          status_value: "Done"
  pr_opened_reopened_review_requested:
    name: pr_opened_reopened_review_requested
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request' && (github.event.action == 'opened' || github.event.action == 'reopened' || github.event.action == 'review_requested')
    steps:
      - name: 'Move PR to "In Progress"'
        uses: leonsteinhaeuser/project-beta-automations@v1.0.2
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          organization: sample-org
          project_id: 1
          resource_node_id: ${{ github.event.pull_request.node_id }}
          status_value: "In Progress"
  pr_ready_for_review:
    name: pr_ready_for_review
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request' && github.event.action == 'ready_for_review'
    steps:
      - name: 'Move PR to "Ready for Review"'
        uses: leonsteinhaeuser/project-beta-automations@v1.0.2
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          organization: sample-org
          project_id: 1
          resource_node_id: ${{ github.event.pull_request.node_id }}
          status_value: "Ready for Review"
  pr_closed:
    name: pr_closed
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request' && github.event.action == 'closed'
    steps:
      - name: 'Move PR to "Closed"'
        uses: leonsteinhaeuser/project-beta-automations@v1.0.2
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          organization: sample-org
          project_id: 1
          resource_node_id: ${{ github.event.pull_request.node_id }}
          status_value: "Done"
```

User based:

```yaml
name: Project automations
on:
  issues:
    types:
      - opened
      - reopened
      - closed
  pull_request:
    types:
      - opened
      - ready_for_review
      - reopened
      - review_requested
      - closed
jobs:
  issue_opened_and_reopened:
    name: issue_opened_and_reopened
    runs-on: ubuntu-latest
    if: github.event_name == 'issues' && (github.event.action == 'opened' || github.event.action == 'reopened')
    steps:
      - name: 'Move issue to "Todo"'
        uses: leonsteinhaeuser/project-beta-automations@v1.0.2
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          user: sample-user
          project_id: 1
          resource_node_id: ${{ github.event.issue.node_id }}
          status_value: "Todo"
  issue_closed:
    name: issue_closed
    runs-on: ubuntu-latest
    if: github.event_name == 'issues' && github.event.action == 'closed'
    steps:
      - name: 'Moved issue to "Done"'
        uses: leonsteinhaeuser/project-beta-automations@v1.0.2
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          user: sample-user
          project_id: 1
          resource_node_id: ${{ github.event.issue.node_id }}
          status_value: "Done"
  pr_opened_reopened_review_requested:
    name: pr_opened_reopened_review_requested
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request' && (github.event.action == 'opened' || github.event.action == 'reopened' || github.event.action == 'review_requested')
    steps:
      - name: 'Move PR to "In Progress"'
        uses: leonsteinhaeuser/project-beta-automations@v1.0.2
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          user: sample-user
          project_id: 1
          resource_node_id: ${{ github.event.pull_request.node_id }}
          status_value: "In Progress"
  pr_ready_for_review:
    name: pr_ready_for_review
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request' && github.event.action == 'ready_for_review'
    steps:
      - name: 'Move PR to "Ready for Review"'
        uses: leonsteinhaeuser/project-beta-automations@v1.0.2
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          user: sample-user
          project_id: 1
          resource_node_id: ${{ github.event.pull_request.node_id }}
          status_value: "Ready for Review"
  pr_closed:
    name: pr_closed
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request' && github.event.action == 'closed'
    steps:
      - name: 'Move PR to "Closed"'
        uses: leonsteinhaeuser/project-beta-automations@v1.0.2
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          user: sample-user
          project_id: 1
          resource_node_id: ${{ github.event.pull_request.node_id }}
          status_value: "Done"
```

## Project board

Since the issues and pull requests from this repository are also managed by this automation, you can take an example from the public project board to see what it looks like.

[Project board](https://github.com/users/leonsteinhaeuser/projects/6).
