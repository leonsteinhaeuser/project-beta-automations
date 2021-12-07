# project-beta-automations

This repository provides the ability to automate GitHub issues and pull requests for [Github Projects (Beta)](https://docs.github.com/en/issues/trying-out-the-new-projects-experience/about-projects). To do this, it automates the **Status** field to put issues and pull requests in the desired status, and therefore the desired column in the Board view. If the issue or pull request is not already in the Project, it will be added.

Note: GITHUB_TOKEN does not have the necessary scopes to access projects (beta).
You must create a token with ***org:write*** scope and save it as a secret in your repository or organization.
For more information, see [Creating a personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).

## Project board

Since the issues and pull requests from this repository are also managed by this automation, you can take an example from the public project board to see what it looks like.

[Project board](https://github.com/users/leonsteinhaeuser/projects/6).

## Variables

| Variable           | Required | Description |
| ------------------ | -------- |----------- |
| `gh_token`         | true     | The GitHub token to use for the automation. |
| `user`             | false    | The GitHub username that owns the projectboard. Either a user or an organization must be specified. |
| `organization`     | false    | The GitHub organization that owns the projectboard. Either a user or an organization must be specified. |
| `project_id`       | true     | The projectboard id. |
| `resource_node_id` | true     | The id of the resource node. |
| `status_value`     | true     | The status value to set. Must be one of the values defined in your project board **Status field settings**. |

## Getting started

The following example assumes that you have a project board with the following columns:

- **Todo**
- **In Progress**
- **Done**

Before we start to automate the project board, we need to define a workflow that matches our requirement. The following table defines a set of actions to automate the board.

| Current Status | Target Status   | Event name  | GitHub event  | Description |
| -------------- | --------------- | ----- | ------------- | ----------- |
| **any**        | **Todo**        | issues | `github.event.action == 'opened'`, `github.event.action == 'reopened'` | Define an automation that moves an issue to the *Todo* column. |
| **any**        | **In Progress** | pull_request    | `github.event.action == 'opened'`, `github.event.action == 'reopened'`, `github.event.action == 'review_requested'` | Define an automation that moves a pull request to the *In Progress* column. |
| **any**        | **Closed**      | issues, pull_request | `github.event.action == 'closed'` | Define an automation that moves an issue or pull request to the *Done* column. |

The resulting workflow file is defined as follows:

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
      - reopened
      - review_requested
      - closed
jobs:
  issue_opened_or_reopened:
    name: issue_opened_or_reopened
    runs-on: ubuntu-latest
    if: github.event_name == 'issues' && github.event.action == 'opened' || github.event.action == 'reopened'
    steps:
      - name: 'Move issue to "Todo"'
        uses: leonsteinhaeuser/project-beta-automations@v1.0.2
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          user: sample-user
          # organization: sample-org
          project_id: 1
          resource_node_id: ${{ github.event.issue.node_id }}
          status_value: "Todo" # Target status
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
          # organization: sample-org
          project_id: 1
          resource_node_id: ${{ github.event.issue.node_id }}
          status_value: "Done" # Target status
  pr_opened_or_reopened_or_reviewrequested:
    name: pr_opened_or_reopened_or_reviewrequested
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request' && github.event.action == 'opened' || github.event.action == 'reopened' || github.event.action == 'review_requested'
    steps:
      - name: 'Move PR to "In Progress"'
        uses: leonsteinhaeuser/project-beta-automations@v1.0.2
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          user: sample-user
          # organization: sample-org
          project_id: 1
          resource_node_id: ${{ github.event.pull_request.node_id }}
          status_value: "In Progress" # Target status
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
          # organization: sample-org
          project_id: 1
          resource_node_id: ${{ github.event.pull_request.node_id }}
          status_value: "Done" # Target status
```

## Detailed example

Since this repository is also covered by this automation, you can take a look at the definition within the [project-automation.yml](.github/workflows/project_automations.yml) file to check how it is defined here.
