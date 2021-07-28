# ASB Auto Deploy

## Delete this directory

- This directory contains the challenges integrated into setup
- Remove from your hack repo after you create

> This directory is for members of the Retail Dev Crews team only
> The scripts will not work outside our environment without modification

## Deploy ASB

> Detailed instructions are in [readme](../readme.md)

- Login to Azure
- Open this repo in Codespaces
- Set Team Name (follow the rules!)
- Create and push to git branch

  ```bash

  # create a branch for your cluster
  git checkout -b $ASB_TEAM_NAME
  git push -u origin $ASB_TEAM_NAME

  ```

- Run setup.sh

  ```bash
  ./setup.sh $ASB_TEAM_NAME
  ```

### Follow the validation steps

### Cleanup ASB

```bash
# run cleanup script to delete ASB

./cleanup.sh -y
```
