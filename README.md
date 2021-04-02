# build-deploy-angular-app-on-github

This action enables you to build your Angular application. It also deploys the distribution bundle to another repository. If you are building your portfolio with Angular and want to host it on GitHub, then this action can get you job done.

# Inputs:

1. **source_branch:** This is the source branch inside the repo.
2. **target_repo** The repo where you want to deploy the distribution bundle.
3. **target_branch:** The branch inside the target repo to which the bundle will be deployed
4. **user_email:** Email of the user
5. **user_name:** Name of the user
6. **commit_message:** Custom commit message
7. **delete_history:** Set this to 'true' if you want to delete history of the repo. Defaults to false
8. **readme:** Name of the readme file for target repo
