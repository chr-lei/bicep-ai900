# Bicep Experiments with the AI-900 Learning Modules

This repo contains Bicep code to deploy Azure resources used throughout the Microsoft Learn AI-900 learning tracks.

This is first and foremost a learning exercise focused on Bicep and deployment stacks. I chose to use the AI-900 related resources as I am also working towards that certification, and I wanted to practice Bicep meaningful set of resources to deploy and experiment with.

This code is not complete, optimized, or polished. Consider it a work in progress and don't use it anywhere important. That said, it does deploy a usable set of resources that can be built upon via the exercises in the AI-900 learning tracks & modules. Some needed resources or configuration tweaks may be missing, but they'll be walked through during the course of the modules.

## Code Layout

The `main.bicep` file is responsible for setting up the resource group and otherwise bootstrapping further deployments.

There are three Bicep modules in use to deploy related portions of the infrastructure:

- `aiservices.bicep` deploys Azure AI service resources & supporting infrastructure
- `mlworkspace.bicep` deploys an Azure Machine Learning Workspace & supporting infrastructure
- `search.bicep` deploys an Azure AI Search (Cognitive Search) resource & supporting infrastructure

### Inputs

The Bicep deployment takes two input parameters at runtime:

- **nameString** - a short string that will be used when naming resources, to add some uniqueness. For example, `clai900`.
- **resourceGroupLocation** - location for the resource group and any resources created within that RG. Note: there are some AI resources that can only be deployed in selected regions. They're identified in the learning modules by explicitly calling for the use of *East US*. I would recommend just setting the resource group location to *East US* for now.

### Outputs

The deployment stack will output:

- **azure_machine_learning_workspace_url** - the URL to access the Azure Machine Learning Workspace console.
- **resource_name_seed** - the resource naming seed (your nameString + some additional randomness) used to name most of the resources in the stack.

## How To Use

Azure Bicep deployment stacks must be deployed using either Azure PowerShell or Azure CLI. The below steps walk through the usage of the CLI to deploy this stack.

First, if you haven't already, log in to your tenant and set your subscription:

```bash
az login
az account set --subscription '_your_subscription_id_'
```

Now, clone this repo into a local folder (or just download the code).

```bash
git clone https://github.com/chr-lei/bicep-ai900
cd bicep-ai900
```

Now, create a deployment stack.

```bash
az stack sub create -f .\bicep\main.bicep --location eastus --name myStack -p nameString=myNameString resourceGroupLocation=eastus --delete-all --deny-settings-mode none
```

The above command breaks down as follows:

- deploy the stack to the `sub` (subscription) scope
- `create` (or update) a deployment stack
- use the `f`ile located at *.\bicep\main.bicep*
  - this could also be a full path, as well. change according to your needs.
- store the deployment metadata in the *eastus* `location`
- `name` the deployment stack *myStack*
- provide the `p`arameters as specified
  - parameter *nameString* = myNameString
  - parameter *resourceGroupLocation* = eastus
- `delete-all` any resources that become unmanaged by the stack (similar to how Terraform will delete a managed resource if it's in state, but no longer specified in the .tf code)
- set the `deny-settings-mode` to none

## To-Do

1. Create storage account resource for the text analysis modules, with containers to store the uploaded coffee reviews, etc.; and public blob access enabled where needed.
2. Add some validation for things like locations (does the selected location support all AI resources, etc.)
3. General input validation
4. Variable naming cleanup, consistency, etc.
