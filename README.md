# primed-inventory-workflows
Workflows for generating the PRIMED inventory workspace

This repository provides WDL workflows for generating inventories of PRIMED data in AnVIL.

Each workflow takes an array of workspaces and associated studies as input.
This input can be automatically created by Coordinating Center staff using the PRIMED AnVIL Consortium Manager app.

## Individual inventory workflows

### General information

Each inventory workflow pulls all records from a set of tables in the input workspaces, concatenates them, and writes te result to a data table in the output workspace.
It also adds columns indicating the source workspace where the records were obtained.

- `input_workspaces`: An array of workspace names to pull data from. This should be a "map" type with the workspace as the key and the studies associated with that workspace as the value. (Example: {"workspace-namespace/workspace-name": "study"})
- `output_workspace_namespace`: The namespace of the workspace to write the inventory to.
- `output_workspace_name`: The name of the workspace to write the inventory to.
- `output_table_name`: The name of the table to write the inventory to.


### Available workflows and associated tables


| Workflow    | Associated tables |
| -------- | ------- |
| `primed_phenotype_inventory`            | `phenotype_harmonized` |
| `primed_genotype_inventory`             | `array_dataset` <br> `imputation_dataset` <br> `sequencing_dataset` <br> `simulation_dataset` |
| `primed_association_analysis_inventory` | `association_analysis` |
| `primed_ancestry_analysis_inventory`    | `ancestry_analysis` |


## primed_inventories workflow

This workflow runs all individual primed inventory workflows (see previous section).

### Inputs

- `input_workspaces`: An array of workspace names to pull data from. This should be a "map" type with the workspace as the key and the studies associated with that workspace as the value. (Example: {"workspace-namespace/workspace-name": "study"})
- `output_workspace_namespace`: The namespace of the workspace to write the inventory to.
- `output_workspace_name`: The name of the workspace to write the inventory to.


## Developer info

### Building and pushing the docker image

1. Push all changes to the repository. Note that the Docker image will build off the "main" branch on GitHub.

1. Build the image. Make sure to include no caching, or else local scripts will not be updated.

    ```bash
    docker build --no-cache -t uwgac/primed-inventory-workflows:X.Y.Z .
    ```

1. Push the image to Docker Hub.

    ```bash
    docker push uwgac/primed-inventory-workflows:X.Y.Z
    ```
