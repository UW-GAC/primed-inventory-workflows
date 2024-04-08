library(AnVIL)
library(AnvilDataModels)
library(tidyverse)

# List of workspaces - this is an input.
workspaces <- c(
  "primed-data-prevent-1/PRIMED_ARIC_DBGAP_PHS000280_V8_P2_HMB-IRB",
  "primed-data-dprism-1/PRIMED_RPGEH_DBGAP_PHS000788_V2_P3_HMB-IRB-NPU",
  "primed-data-topmed-1/PRIMED_CARDIA_TOPMED_DBGAP_PHS001612_V1_P1_HMB-IRB",
  NULL
)

get_phenotype_inventory_table_for_workspace <- function(workspace) {
  table_name <- "phenotype_harmonized"

  workspace_namespace = str_split_1(workspace, pattern="/")[1]
  workspace_name = str_split_1(workspace, pattern="/")[2]
  tables <- avtables(namespace=workspace_namespace, name=workspace_name)
  if (table_name %in% tables$table) {
    table <- avtable("phenotype_harmonized", namespace=workspace_namespace, name=workspace_name)
    x <- table %>%
      # phenotype_harmonized_id is needed to make the table unique.
      select(phenotype_harmonized_id, table=domain, n_subjects, n_rows, file_path)
  }
  else {
    x = tibble()
  }
  return(x)
}

# Loop over workspaces and get phenotype_harmonized table.

results_list <- list()

workspace <- workspaces[1]
for (workspace in workspaces) {
  results_list[[workspace]] <- get_phenotype_inventory_table_for_workspace(workspace)
}

results <- bind_rows(results_list, .id="workspace") %>%
  rename(
    phenotype_inventory_id=phenotype_harmonized_id
  ) %>%
  select(phenotype_inventory_id, everything())

# Set up output workspace info.
output_workspace = avworkspace() # This will be different when we actually run the script.
output_workspace_namespace = str_split_1(output_workspace, pattern="/")[1]
output_workspace_name = str_split_1(output_workspace, pattern="/")[2]

# Get the original results
table_name <- "phenotype_inventory"
tables <- avtables(namespace=output_workspace_namespace, name=output_workspace_name)
if (table_name %in% tables$table) {
  original_results <- avtable(table_name, namespace=output_workspace_namespace, name=output_workspace_name)
  avtable_delete_values(table_name, original_results$phenotype_inventory_id)
}

# Write the new results the table.
# Note: anvil_import_Tables will check job status and timeout after an hour (by default).
anvil_import_tables(list(phenotype_inventory=results), namespace=output_workspace_namespace, name=output_workspace_name, overwrite=TRUE)

# Delete any rows from the original table that weren't in the new table.
(job_status <- avtable_import_status(job_status))
