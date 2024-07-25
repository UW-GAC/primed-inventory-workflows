# primed-inventory-workflows
Workflows for generating the PRIMED inventory workspace

This repository provides WDL workflows for generating inventories of PRIMED data in AnVIL.

Each workflow takes an array of workspaces and associated studies as input.
This input can be automatically created by Coordinating Center staff using the PRIMED AnVIL Consortium Manager app.


## primed_phenotype_inventory

This workflow pulls all records from the `phenotype_harmonized` table in the input workspace, concatenates them, and writes the result to a data table in the output workspace.
It also adds columns indicating the source workspace where the records were obtained.

### Inputs

- `input_workspaces`: An array of workspace names to pull data from. This should be a "map" type with the workspace as the key and the studies associated with that workspace as the value. (Example: {"workspace-namespace/workspace-name": "study"})
- `output_workspace_namespace`: The namespace of the workspace to write the inventory to.
- `output_workspace_name`: The name of the workspace to write the inventory to.
- `output_table_name`: The name of the table to write the inventory to.


## primed_genotype_inventory

This workflow pulls all records from the genotype dataset tables in the input workspace, concatenates them, and writes the result to a data table in the output workspace.
It also adds columns indicating the source workspace where the records were obtained.

### Inputs

- `input_workspaces`: An array of workspace names to pull data from. This should be a "map" type with the workspace as the key and the studies associated with that workspace as the value. (Example: {"workspace-namespace/workspace-name": "study"})
- `output_workspace_namespace`: The namespace of the workspace to write the inventory to.
- `output_workspace_name`: The name of the workspace to write the inventory to.
- `output_table_name`: The name of the table to write the inventory to.


## primed_inventories

This workflow runs both the `primed_phenotype_inventory` and the `primed_phenotype_inventory` workflows.

### Inputs

- `input_workspaces`: An array of workspace names to pull data from. This should be a "map" type with the workspace as the key and the studies associated with that workspace as the value. (Example: {"workspace-namespace/workspace-name": "study"})
- `output_workspace_namespace`: The namespace of the workspace to write the inventory to.
- `output_workspace_name`: The name of the workspace to write the inventory to.
