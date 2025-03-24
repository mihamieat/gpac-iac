# gpac-iac

IaC repository of our G-Pac project

## Environment variables to set in GitHub Actions secret variables
| Variable Name              | Description |
|----------------------------|-------------|
| `SSH_PRIVATE_KEY` | The SSH public key used for authenticating to EC2 instances.|
| `TF_CLOUD_ORGANIZATION`    | The name of the Terraform Cloud organization where the workspaces are managed. |
| `TF_WORKSPACE`             | The name of the current Terraform workspace. |
| `TF_WORKSPACE_KEY`         | A unique identifier or API key related to a specific Terraform workspace. |

## Contribute 

### pre-commit
```sh
pipx install pre-commit
pre-commit install
pre-commit run -a # to test
```
