# primed-inventory-workflows
Workflows for generating the PRIMED inventory workspace


# Notes for development

Decisions after discussion with Stephanie:

- Input should be a json/map where the key is billingproject/workspace and the value is the string of studies
  - Use the write map function in WDL! See validation workflows - they use it
- Write directly to the final phenotype inventory table - do not create a tsv
- Delete the final phenotype inventory table and rewrite each time the workflow is run
  - Look at avtables_delete_values - cannot delete an entire table using the AnVIL Bioconductor R package
- What is the primary key of the phenotype_inventory table? can just use phenotype_harmonized_id from the phenotype_harmonized table, need to rename to phenotype_inventory_id per AnVIL requirements
