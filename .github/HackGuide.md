# ASB Hack Guide

> This is an early draft

## Setup

### Process

- Identify Coaches
  - Questions will come up
- Challenge Ideas
  - Overview presentation and first setup takes most of a day
  - What's next?
  - Some teams will come up with their own ideas
  - There is a /challenges folder
    - Check in WIP
- Stand ups
  - We generally do two stand ups / day
  - Demos at the afternoon stand up!
- Retros
  - We had 30 minutes of challenge demos
  - 30 minutes of retro

### Azure Subscription

- You need an Azure Subscription with AAD permissions
- This will not currently work in an AIRS subscription
- Create an AAD hack group
  - Grant AAD User Admin permissions
  - Grant Azure Subscription Contributor permissions
- Create Users
  - Add to AAD hack group
  - Email login info and validate Azure access before hack starts
- Check Azure Quotas and increase if needed
  - Public IPs defaults to 100 and each cluster needs 4 PIPs
  - Each cluster deploys 5 VMs

### Repo Setup

- Clone (not fork) this repo
- Set the `ASB_TENANT_ID` repo secret to your Azure Subscription Tenant ID
- Make sure your org has GitHub Codespaces access
- Add users to GitHub org
- Grant write privelege to repo

### Communication Setup

- Setup Teams or use GitHub Discussions
  - Most hacks will have multiple smaller breakout teams
  - Add coaches to breakout teams

## Execution

> Duration: 3-4 days is adequate time to go deeper via `Challenges`

### Day 1 Agenda

- Intros
- Validate and resolve access
- Review `Working Agreement` and `Code of Conduct`
- AKS Secure Baseline Overview and Architecture
  - We used the PnP repo and Azure Portal of a deployed cluster
- Break into teams of 4-6
  - Each team deploys ASB
- Stand Up and Planning
  - Stand up
  - Encourage attendees to clean up unused clusters
  - Plan Challenge Teams
    - We let attendees self-select
    - 2-5 seems ideal
    - Coaches support

### Day 2+ Agenda

- Stand up
  - Make sure everyone is on a challenge team
- Hack on Challenges
- Stand up
  - Demos
  - Adjust / create new challenge teams
  - Encourage attendees to clean up unused clusters

### Day n Agenda

- Finish demos
- PR work into main branch (/challenges directory)
- Clean up unused clusters
- Demos, demos, demos
- Retrospective

### Tips

- Tightly couple `teams` to `branches`
  - GitOps is really challenging otherwise
  - The ASB_TEAM_NAME really is picky ...
  - Do NOT merge team (cluster) branches into main
    - There are 5 files that are generated and should never be in main
- Open the `readme` in a browser on GitHub
  - This gives you a copy button for the fences
    - Codespaces does not
    - This avoids copy-paste errors
- Beware `soft deletes`
  - Deployment will fail if the name is reused and a soft delete exists
  - Make sure to run `./cleanup.sh`
  - Partial deploys have to be deleted by hand
  - Soft deleted key vaults are easy to purge from the portal
  - Soft delete Log Analytics Workspaces are not
- One person should drive the entire initial setup
  - Do not try to switch off in the middle the first time
- Once setup, everything the other team members need is in the team branch
  - Make sure to add each team member to the cluster admin group
