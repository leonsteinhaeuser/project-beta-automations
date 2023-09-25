# project-beta-automations

[![latest release](https://img.shields.io/github/v/release/leonsteinhaeuser/project-beta-automations)](https://img.shields.io/github/v/release/leonsteinhaeuser/project-beta-automations)
[![release date](https://img.shields.io/github/release-date/leonsteinhaeuser/project-beta-automations)](https://img.shields.io/github/release-date/leonsteinhaeuser/project-beta-automations)
[![commits since release](https://img.shields.io/github/commits-since/leonsteinhaeuser/project-beta-automations/latest)](https://img.shields.io/github/commits-since/leonsteinhaeuser/project-beta-automations/latest)
[![open: bugs](https://img.shields.io/github/issues/leonsteinhaeuser/project-beta-automations/bug)](https://img.shields.io/github/issues/leonsteinhaeuser/project-beta-automations/bug)
[![open: feature requests](https://img.shields.io/github/issues/leonsteinhaeuser/project-beta-automations/feature%20request)](https://img.shields.io/github/issues/leonsteinhaeuser/project-beta-automations/feature%20request)
[![issues closed](https://img.shields.io/github/issues-closed/leonsteinhaeuser/project-beta-automations)](https://img.shields.io/github/issues-closed/leonsteinhaeuser/project-beta-automations)
[![license](https://img.shields.io/github/license/leonsteinhaeuser/project-beta-automations)](https://img.shields.io/github/license/leonsteinhaeuser/project-beta-automations)

This automation provides the ability to automate issues and pull requests related to [Github Projects (Beta)](https://docs.github.com/en/issues/trying-out-the-new-projects-experience/about-projects).
If the issue or pull request is not attached to a project, it is automatically added to the project and its desired column.
In addition to status automation, this automation also supports custom field management.

Note: GITHUB_TOKEN does not have the necessary scopes to access projects (beta).
You must create a token with ***org:write*** scope and save it as a secret in your repository or organization.
For more information, see [Creating a personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).

> :warning: The GitHub API change of 2022-02-23 results in an error message requiring an upgrade to a new version.
>
> What is the problem?
>
> As of 2022-02-23 , the GitHub API requires that the value of a single select/iteration field be a string instead of an ID!
>
> This causes the automation to throw an error message.
>
> https://github.blog/changelog/2022-02-23-the-new-github-issues-february-23rd-update/

## V1 vs V2

In June 2022, [GitHub announced a breaking change to the Projects API](https://github.blog/changelog/2022-06-23-the-new-github-issues-june-23rd-update/). Therefore, the @v1 tag of this action will stop working on October 1, 2022. You can switch to the @v2 tag at any time (by updating the reference in your workflow file).

## Project board

Since the issues and pull requests from this repository are also managed by this automation, you can take an example from the public project board to see what it looks like.

[Project board](https://github.com/users/leonsteinhaeuser/projects/6).

## Variables

| Variable                 | Required | Description                                                                                                                                                                                                                                  |
|--------------------------| -------- |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `gh_host`                | false    | The GitHub hostname of the enterpise installation to use for the automation. For App instructions refer to [GH App Auth](#GH-App-Auth).                                                                                                      |
| `gh_token`               | false    | The GitHub token to use for the automation. For App instructions refer to [GH App Auth](#GH-App-Auth). (`gh_token` or `gh_app_*` must be defined)                                                                                            |
| `gh_app_ID`              | false    | The GitHub App ID used for App authentication. For App instructions refer to [GH App Auth](#GH-App-Auth). (`gh_token` or `gh_app_*` must be defined)                                                                                         |
| `gh_app_installation_ID` | false    | The Github App installation ID binding the App to the target org. For App instructions refer to [GH App Auth](#GH-App-Auth). (`gh_token` or `gh_app_*` must be defined)                                                                      |
| `gh_app_secret_key`      | false    | The Github App Secret key used to sign App JWT tokens. For App instructions refer to [GH App Auth](#GH-App-Auth). (`gh_token` or `gh_app_*` must be defined)                                                                                 |
| `user`                   | false    | The GitHub username that owns the projectboard. Either a user or an organization must be specified.                                                                                                                                          |
| `organization`           | false    | The GitHub organization that owns the projectboard. Either a user or an organization must be specified.                                                                                                                                      |
| `project_id`             | true     | The projectboard id.                                                                                                                                                                                                                         |
| `resource_node_id`       | true     | The id of the resource node.                                                                                                                                                                                                                 |
| `status_value`           | false    | The status value to set. Must be one of the values defined in your project board **Status field settings**. If left unspecified, new items are added without an explicit status, and existing items are left alone.                          |
| `operation_mode`         | false    | The operation mode to use. Must be one of `custom_field`, `status`. Defaults to: `status`                                                                                                                                                    |
| `custom_field_values`    | false    | Provides the possibility to change custom fields. To be applied the **operation_mode** must be set to `custom_field`. For the json definition refer to [JSON-Definition](#JSON-Definition)                                                   |
| `move_related_issues`    | false | If set to `true` and the operation mode is set to `status`, the automation will also move related issues to the same column. This is useful if you want to move an issue to the same column as its related pull request. Defaults to: `false` |

## Getting started

The following example assumes that you have a project board with the following columns:

- **Todo**
- **In Progress**
- **Done**

Before we start to automate the project board, we need to decide whether we want to manage the **Status** field using this action or the workflow definition of the project board. Keep in mind that until now there is no way to automatically add issues or pull requests to the project board using the provided workflow functionality by GitHub. The next example assumes that you decided to use this action to manage the **Status** field.

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

# map fields with customized labels
env:
  todo: Todo ✏️
  done: Done ✅
  in_progress: In Progress 🚧

jobs:
  issue_opened_or_reopened:
    name: issue_opened_or_reopened
    runs-on: ubuntu-latest
    if: github.event_name == 'issues' && (github.event.action == 'opened' || github.event.action == 'reopened')
    steps:
      - name: Move issue to ${{ env.todo }}
        uses: leonsteinhaeuser/project-beta-automations@v2.1.0
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          user: sample-user
          # organization: sample-org
          project_id: 1
          resource_node_id: ${{ github.event.issue.node_id }}
          status_value: ${{ env.todo }} # Target status
  issue_closed:
    name: issue_closed
    runs-on: ubuntu-latest
    if: github.event_name == 'issues' && github.event.action == 'closed'
    steps:
      - name: Moved issue to ${{ env.done }}
        uses: leonsteinhaeuser/project-beta-automations@v2.1.0
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          user: sample-user
          # organization: sample-org
          project_id: 1
          resource_node_id: ${{ github.event.issue.node_id }}
          status_value: ${{ env.done }} # Target status
  pr_opened_or_reopened_or_reviewrequested:
    name: pr_opened_or_reopened_or_reviewrequested
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request' && (github.event.action == 'opened' || github.event.action == 'reopened' || github.event.action == 'review_requested')
    steps:
      - name: Move PR to ${{ env.in_progress }}
        uses: leonsteinhaeuser/project-beta-automations@v2.1.0
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          user: sample-user
          # organization: sample-org
          project_id: 1
          resource_node_id: ${{ github.event.pull_request.node_id }}
          status_value: ${{ env.in_progress }} # Target status
  pr_closed:
    name: pr_closed
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request' && github.event.action == 'closed'
    steps:
      - name: Move PR to ${{ env.done }}
        uses: leonsteinhaeuser/project-beta-automations@v2.1.0
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          user: sample-user
          # organization: sample-org
          project_id: 1
          resource_node_id: ${{ github.event.pull_request.node_id }}
          status_value: ${{ env.done }} # Target status
```

### Allowing the workflow to run on PR's coming from forks

To allow PR from a fork to run the workflow use `pull_request_target` instead of `pull_request` like the example below.

```yaml
name: Project automations

on:
  pull_request_target:
    types:
      - opened
      - closed

# map fields with customized labels
env:
  done: Done ✅
  in_progress: In Progress 🚧

jobs:
  pr_opened:
    name: pr_opened
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request_target' && github.event.action == 'opened'
    steps:
      - name: Move PR to ${{ env.in_progress }}
        uses: leonsteinhaeuser/project-beta-automations@v2.1.0
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          user: sample-user
          # organization: sample-org
          project_id: 1
          resource_node_id: ${{ github.event.pull_request.node_id }}
          status_value: ${{ env.in_progress }} # Target status
  pr_closed:
    name: pr_closed
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request_target' && github.event.action == 'closed'
    steps:
      - name: Move PR to ${{ env.done }}
        uses: leonsteinhaeuser/project-beta-automations@v2.1.0
        with:
          gh_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
          user: sample-user
          # organization: sample-org
          project_id: 1
          resource_node_id: ${{ github.event.pull_request.node_id }}
          status_value: ${{ env.done }} # Target status
```

Without replacing `pull_request` by `pull_request_target` the workflow will fail with `No GH Auth method configured, provide PAT or App ID/Key`.

```
gh cli is installed.
Run echo "No GH Auth method configured, provide PAT or App ID/Key"; exit 1
  echo "No GH Auth method configured, provide PAT or App ID/Key"; exit 1
  shell: /usr/bin/bash --noprofile --norc -e -o pipefail {0}
  env:
    in_review: In Review
No GH Auth method configured, provide PAT or App ID/Key
Error: Process completed with exit code 1.
```

> :warning: Warning
>
> For workflows that are triggered by the `pull_request_target` event, the `GITHUB_TOKEN` is granted read/write repository permission unless the `permissions` key is specified and the workflow can access secrets, even when it is triggered from a fork. Although the workflow runs in the context of the base of the pull request, you should make sure that you do not check out, build, or run untrusted code from the pull request with this event. Additionally, any caches share the same scope as the base branch. To help prevent cache poisoning, you should not save the cache if there is a possibility that the cache contents were altered.

## GH App Auth

To leverage the App authentication with this action the following steps are needed:

- Create a GitHub App under your user or organisation as described in the [GitHub documentation](https://docs.github.com/en/developers/apps/building-github-apps/creating-a-github-app), note the App ID
- Set the needed GitHub App permissions in order for the newly create App to access and manage Org Project, as described in the [GitHub documentation](https://docs.github.com/en/developers/apps/managing-github-apps/editing-a-github-apps-permissions). The minimum required permissions are:
  - Repo: Actions: RW
  - Repo: Checks: RO
  - Repo: Contents: RO
  - Repo: Environments: RO
  - Repo: Issues: RW
  - Repo: Metadata: RO
  - Repo: PR: RW
  - Repo: Commit statuses: RO
  - Org: Members: RO
  - Org: Projects: RW
- Create a private key to authenticate the newly created GitHub App as described in the [GitHub documentation](https://docs.github.com/en/developers/apps/building-github-apps/authenticating-with-github-apps), treat the downloaded key as sensitive material, store it in a GitHub secret accessible by this action.
- Install the app in the target organisation, note the installation ID
- Configure this action with
  - `gh_app_secret_key` containing the aforementioned private key
  - `gh_app_ID` containing the app ID, auto-generated by GitHub in the first step
  - `gh_app_installation_ID` containing the installation ID, auto-generated by GitHub in the previous step. Binging the App to the Org

## JSON-Definition

A single json object is defined as follows:

```json
{
  "name": "Sample Text Field", # defines the name of the custom field
  "type": "text", # can be one of: text, number, date, single_select, iteration
  "value": "High" # defines the value to set (string)
}
```

The json definition that must be passed to the `custom_field_values` argument looks like:

```json
[
  {
    "name": "Priority",
    "type": "single_select",
    "value": "High"
  }
  {
    "name": "Context",
    "type": "text",
    "value": "Just a random text"
  }
]
```

A detailed example can be found inside the [test.sh](test.sh) file. Note that json definition must be enclosed in an array and escaped with double quotes and backslashes.

Example:

```yaml
'[{\"name\": \"Priority\",\"type\": \"text\",\"value\": \"uuid1\"},{\"name\": \"Number\",\"type\": \"number\",\"value\": \"100\"},{\"name\": \"Date\",\"type\": \"date\",\"value\": \"2022-01-28T20:02:27.306+01:00\"},{\"name\": \"Single Select\",\"type\": \"single_select\",\"value\": \"Option 1\"},{\"name\": \"Iteration\",\"type\": \"iteration\",\"value\": \"Iteration 1\"}]'
```

The following example assumes that your project has the following fields defined:

- `Priority`: As *text* field
- `Number`: As *number* field
- `Date`: As *date* field
- `Single Select`: As *single_select* field with options:
  - `Option 1`
  - `Option 2`
  - `Option 3`
- `Iteration`: As *iteration* field with iterations:
  - `Iteration 1`
  - `Iteration 2`
  - `Iteration 3`

```yaml
name: Project automations (organization)

on:
  issues:
  pull_request:

env:
  gh_project_token: ${{ secrets.PAC_TOKEN }}
  project_id: 1
  gh_organization: sample-org
  status_todo: "Todo"
  status_in_progress: "In Progress"
  custom_field_values: '[{\"name\": \"Priority\",\"type\": \"text\",\"value\": \"uuid1\"},{\"name\": \"Number\",\"type\": \"number\",\"value\": \"100\"},{\"name\": \"Date\",\"type\": \"date\",\"value\": \"2022-01-28T20:02:27.306+01:00\"},{\"name\": \"Single Select\",\"type\": \"single_select\",\"value\": \"Option 1\"},{\"name\": \"Iteration\",\"type\": \"iteration\",\"value\": \"Iteration 1\"}]'

jobs:
  issue_opened_or_reopened:
    name: issue_opened_or_reopened
    runs-on: ubuntu-latest
    if: github.event_name == 'issues' && (github.event.action == 'opened' || github.event.action == 'reopened')
    steps:
      - name: 'Move issue to ${{ env.status_todo }}'
        uses: leonsteinhaeuser/project-beta-automations@v2.1.0
        env:
          DEBUG_LOG: "true"
        with:
          gh_token: ${{ env.gh_project_token }}
          organization: ${{ env.gh_organization }}
          project_id: ${{ env.project_id }}
          resource_node_id: ${{ github.event.issue.node_id }}
          status_value: ${{ env.status_todo }}

  issue_project_custom_field_update:
    name: issue_opened_or_reopened
    runs-on: ubuntu-latest
    if: github.event_name == 'issues'
    needs:
      - issue_opened_or_reopened
    steps:
      - name: 'Modify custom fields'
        uses: leonsteinhaeuser/project-beta-automations@v2.1.0
        env:
          DEBUG_LOG: "true"
        with:
          gh_token: ${{ env.gh_project_token }}
          organization: ${{ env.gh_organization }}
          project_id: ${{ env.project_id }}
          resource_node_id: ${{ github.event.issue.node_id }}
          operation_mode: custom_field
          custom_field_values: ${{ env.custom_field_values }}

  pr_opened_or_reopened:
    name: pr_opened_or_reopened
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request' && (github.event.action == 'opened' || github.event.action == 'reopened')
    steps:
      - name: 'Move PR to ${{ env.status_in_progress }}'
        uses: leonsteinhaeuser/project-beta-automations@v2.1.0
        env:
          DEBUG_LOG: "true"
        with:
          gh_token: ${{ env.gh_project_token }}
          organization: ${{ env.gh_organization }}
          project_id: ${{ env.project_id }}
          resource_node_id: ${{ github.event.pull_request.node_id }}
          status_value: ${{ env.status_in_progress }}

  pr_custom_field_update_1:
    name: pr_custom_field_update_1 from env
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    needs:
      - pr_opened_or_reopened
    steps:
      - name: 'Modify custom fields'
        uses: leonsteinhaeuser/project-beta-automations@v2.1.0
        env:
          DEBUG_LOG: "true"
        with:
          gh_token: ${{ env.gh_project_token }}
          organization: ${{ env.gh_organization }}
          project_id: ${{ env.project_id }}
          resource_node_id: ${{ github.event.pull_request.node_id }}
          operation_mode: custom_field
          custom_field_values: ${{ env.custom_field_values }}
```

Since version 1.3.0 the iteration field also supports the following values:

- @current: the current iteration
- @next: the next iteration

Both of these values are provided by the `project-beta-automations` package. The following json provides an example of how to use these values:

Next iteration:

```yaml
'[{\"name\": \"Iteration\",\"type\": \"iteration\",\"value\": \"@next\"}]'
```

Current iteration:

```yaml
'[{\"name\": \"Iteration\",\"type\": \"iteration\",\"value\": \"@current\"}]'
```

## Detailed example

Since this repository is also covered by this automation, you can take a look at the definition within the [project-automation.yml](.github/workflows/project_automations.yml) file to check how it is defined here.

## Debugging

Since debugging is key when tracing a bug, we decided to provide a two step debugging process. To enable the different debugging outputs, you can set the following environment variables:

| Variable         | Option | Default behaviour | Description |
| ---------------- | -------| ----------------- | -------------------------------------------------- |
| `DEBUG_COMMANDS` | `true` | Do nothing        | Enables the stacktrace for command executions.     |
| `DEBUG_LOG`      | `true` | Do nothing        | Prints out the responses produced by the commands. |

Example workflow definition:

```yaml
env:
  todo: Todo ✏️
  gh_project_token: ${{ secrets.PERSONAL_ACCESS_TOKEN }}
  user: sample-user
  project_id: 1

jobs:
  issue_opened:
    name: issue_opened
    runs-on: ubuntu-latest
    if: github.event_name == 'issues' && github.event.action == 'opened'
    steps:
      - name: Move issue to ${{ env.todo }}
        uses: leonsteinhaeuser/project-beta-automations@v2.1.0
        env:
          DEBUG_COMMANDS: true
          DEBUG_LOG: true
        with:
          gh_token: ${{ env.gh_project_token }}
          user: ${{ env.user }}
          # organization: sample-org
          project_id: ${{ env.project_id }}
          resource_node_id: ${{ github.event.issue.node_id }}
          status_value: ${{ env.todo }}
```
