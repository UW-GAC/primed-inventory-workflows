library(argparser)
library(AnVIL)
library(AnvilDataModels)
library(dplyr)
library(readr)
library(tidyr)
library(stringr)


argp <- arg_parser("write_phenotype_inventory_table.R", description="Write phenotype inventory table for shared workspaces.")
argp <- add_argument(argp, "--workspaces-file", help="2-column tsv file with (workspace, studies)")
argp <- add_argument(argp, "--output-workspace-namespace", help="Namespace of the AnVIL workspace to write the phenotype inventory table to.")
argp <- add_argument(argp, "--output-workspace-name", help="Name of the AnVIL workspace to write the phenotype inventory table to.")
argp <- add_argument(argp, "--output-table-name", help="Name of the data table to write the phenotype inventory table to.")
argv <- parse_args(argp)

# Read in the workspaces.
x <- read_tsv(argv$workspaces_file, col_names=c("workspace", "studies"))
# workspaces <- tribble(
#   ~workspace, ~studies,
#   "primed-data-prevent-1/PRIMED_ARIC_DBGAP_PHS000280_V8_P2_HMB-IRB", "ARIC",
#   "primed-data-dprism-1/PRIMED_RPGEH_DBGAP_PHS000788_V2_P3_HMB-IRB-NPU", "GERA, RPGEH",
#   "primed-data-topmed-1/PRIMED_CARDIA_TOPMED_DBGAP_PHS001612_V1_P1_HMB-IRB", "CARDIA"
# )

# Split workspace into namespace and name.
workspaces <- x %>%
  separate(
    workspace,
    into=c("workspace_namespace", "workspace_name"),
    sep="/",
    remove=FALSE
  )

# Just a check:
print(workspaces)

# Loop over workspaces and pull the phenotype inventory information.
results_list <- list()
for (i in seq_along(workspaces$workspace)) {
  input_table_name <- "phenotype_harmonized"

  workspace = workspaces$workspace[i]
  workspace_namespace = workspaces$workspace_namespace[i]
  workspace_name = workspaces$workspace_name[i]

  tables <- avtables(namespace=workspace_namespace, name=workspace_name)
  if (input_table_name %in% tables$table) {
    x <- avtable(input_table_name, namespace=workspace_namespace, name=workspace_name)
  }
  else {
    x = tibble()
  }
  results_list[[workspace]] <- x
}

# Combine the results into a single data frame.
results <- bind_rows(results_list, .id="workspace") %>%
  left_join(workspaces, by="workspace")

# Set up output workspace info.
# output_workspace = avworkspace() # This will be different when we actually run the script.
# output_workspace_namespace = str_split_1(output_workspace, pattern="/")[1]
# output_workspace_name = str_split_1(output_workspace, pattern="/")[2]
output_workspace_namespace = argv$output_workspace_namespace
output_workspace_name = argv$output_workspace_name
output_table_name = argv$output_table_name

id_column_name = quo_name(paste0(output_table_name, "_id"))
results <- results %>%
  # We separated workspace into namespace and name, so we don't need it anymore.
  select(-workspace) %>%
  rename(
    # Set the id column appropriately, using the output table name.
    !!id_column_name := phenotype_harmonized_id
  )
print(results)

# Delete the table before writing the new data, if it already exists.
tables <- avtables(namespace=output_workspace_namespace, name=output_workspace_name)
if (output_table_name %in% tables$table) {
  original_results <- avtable(output_table_name, namespace=output_workspace_namespace, name=output_workspace_name)
  avtable_delete_values(output_table_name, original_results[[id_column_name]], namespace=output_workspace_namespace, name=output_workspace_name)
}

tables <- list(tmp=results) %>%
  setNames(output_table_name)

# Write the new results the table.
# Note: anvil_import_tables will check job status and timeout after an hour (by default).
anvil_import_tables(tables, namespace=output_workspace_namespace, name=output_workspace_name, overwrite=TRUE)
