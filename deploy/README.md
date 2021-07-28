# ASB Auto Deploy

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

- Push Updates

  ```bash

  # load the env vars created by setup
  # you can reload the env vars at any time by sourcing the file
  source ${ASB_TEAM_NAME}.asb.env

  # check deltas - there should be 5 new files
  git status

  # push to your branch
  git add .
  git commit -m "added cluster config"
  git push

  ```

- Follow the validation steps

### Cleanup ASB

```bash
# run cleanup script to delete ASB

./cleanup.sh -y
```
