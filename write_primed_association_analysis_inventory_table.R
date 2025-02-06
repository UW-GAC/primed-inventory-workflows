library(argparser)
library(AnVILGCP)
library(AnvilDataModels)
library(dplyr)
library(readr)
library(tidyr)
library(stringr)


argp <- arg_parser("write_primed_association_analysis_inventory_table.R", description="Write association analysis inventory table for shared workspaces.")
argp <- add_argument(argp, "--workspaces-file", help="2-column tsv file with (workspace, studies)")
argp <- add_argument(argp, "--output-workspace-namespace", help="Namespace of the AnVIL workspace to write the inventory table to.")
argp <- add_argument(argp, "--output-workspace-name", help="Name of the AnVIL workspace to write the inventory table to.")
argp <- add_argument(argp, "--output-table-name", help="Name of the data table to write the inventory table to.")
argv <- parse_args(argp)

# Read in the workspaces.
x <- read_tsv(argv$workspaces_file, col_names=c("workspace", "studies"))
# x <- tribble(
#   ~workspace, ~studies,
#   "primed-data-primed-cancer-open/PRIMED_LUNG_PMID35915169", "GWAS Catalog, Lung-GSRs",
#   "primed-data-cc-open/PRIMED_PAN_UKBB_GSR_ANTHROPOMETRY", "UKBB",
# )

tables_to_combine <- c(
  "association_analysis"
)

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

# Loop over workspaces and pull the dataset information.
results_list <- list()
for (i in seq_along(workspaces$workspace)) {
  print(paste("Processing workspace:", workspaces$workspace[i]))
  # Loop over the different tables.
  workspace_results_list <- list()
  for (input_table_name in tables_to_combine) {

    workspace = workspaces$workspace[i]
    workspace_namespace = workspaces$workspace_namespace[i]
    workspace_name = workspaces$workspace_name[i]

    tables <- avtables(namespace=workspace_namespace, name=workspace_name)
    if (input_table_name %in% tables$table) {
      x <- avtable(input_table_name, namespace=workspace_namespace, name=workspace_name)
      # Subset to and rename the id column.
      id_column_name = quo_name(paste0(input_table_name, "_id"))
    #   x <- x %>%
    #     select(
    #       dataset_id = !!id_column_name,
    #       reference_assembly,
    #       sample_set_id
    #     )
    #   # Pull the sample set table and calculate the number of samples
    #   number_of_samples <- avtable("sample_set", namespace=workspace_namespace, name=workspace_name) %>%
    #     unnest_set_table() %>%
    #     count(sample_set_id, name="n_samples")
    #   x <- x %>% left_join(number_of_samples, by="sample_set_id")
    }
    else {
      x = tibble()
    }
    workspace_results_list[[input_table_name]] <- x
  }
  results_list[[workspace]] <- bind_rows(workspace_results_list)
}

# Combine the results into a single data frame.
results <- bind_rows(results_list, .id="workspace") %>%
  left_join(workspaces, by="workspace")

# Set up output workspace info.
# output_workspace = avworkspace() # This will be different when we actually run the script.
# output_workspace_namespace = str_split_1(output_workspace, pattern="/")[1]
# output_workspace_name = str_split_1(output_workspace, pattern="/")[2]
# output_table_name <- "tmp_genotype_inventory"
output_workspace_namespace = argv$output_workspace_namespace
output_workspace_name = argv$output_workspace_name
output_table_name = argv$output_table_name

id_column_name = quo_name(paste0(output_table_name, "_id"))
results <- results %>%
  select(association_analysis_id, everything()) %>%
  rename(!!id_column_name := association_analysis_id) %>%
  # We separated workspace into namespace and name, so we don't need it anymore.
  select(-workspace)
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
