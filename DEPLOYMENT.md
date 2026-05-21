# Deployment automation

This repository deploys with Docker Compose from the parent repository, while each
application lives in a Git submodule.

## Flow

1. A submodule repository receives a push on `develop` or `feature/dockernize`.
2. The submodule workflow sends a `repository_dispatch` event to the parent
   repository with the pushed module path, branch, and commit SHA.
3. The parent workflow updates the matching submodule pointer, commits that
   gitlink change to the parent repository, and pushes it to the deploy branch.
4. The parent workflow runs on a self-hosted runner that can reach the
   deployment server over the internal network.
5. The server pulls the parent repository, updates submodules to the SHAs
   recorded by the parent repository, and deploys with
   `docker compose up -d --build`.

The parent workflow can also be run manually from GitHub Actions with the
`workflow_dispatch` trigger. Manual runs can optionally deploy a specific
submodule branch without committing a parent repository pointer update.

## Parent repository secrets

Set these secrets in the parent deployment repository:

- `DEPLOY_HOST`: deployment server hostname or IP
- `DEPLOY_USER`: SSH username
- `DEPLOY_DIR`: absolute path to this repository on the deployment server
- `DEPLOY_PORT`: SSH port, optional, defaults to `22`

The SSH key is expected to already exist on the self-hosted runner account that
executes the workflow.

Optional repository variable:

- `DEPLOY_BRANCH`: parent repository branch to deploy, defaults to `develop`

The parent repository workflow needs `Contents: read and write` workflow
permissions so it can commit the updated submodule pointer. If the deploy branch
is protected, allow the workflow token or use a token that can push to that
branch.

## Submodule repository secrets

Set this secret in each submodule repository:

- `PARENT_REPO_DISPATCH_TOKEN`: GitHub token that can create
  `repository_dispatch` events in the parent repository. For a fine-grained
  personal access token, grant access to the parent repository with contents
  write permission.

Optional repository variable:

- `DEPLOY_REPOSITORY`: parent repository full name, defaults to
  `Batterfly-co/Legacy_Demo_Deploy`
