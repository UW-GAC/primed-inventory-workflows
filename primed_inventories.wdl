version 1.0

import "primed_phenotype_inventory.wdl" as phenotype_inventory
import "primed_genotype_inventory.wdl" as genotype_inventory

workflow primed_inventories {
    input {
        Map[String, String] workspaces
        String output_workspace_name
        String output_workspace_namespace
    }

    call phenotype_inventory.write_primed_phenotype_inventory_table {
        input: workspaces = workspaces,
                output_workspace_name = output_workspace_name,
                output_workspace_namespace = output_workspace_namespace,
                output_table = "phenotype_inventory"
    }

    call genotype_inventory.write_primed_genotype_inventory_table {
        input: workspaces = workspaces,
                output_workspace_name = output_workspace_name,
                output_workspace_namespace = output_workspace_namespace,
                output_table = "genotype_inventory"
    }

    meta {
          author: "Adrienne stilp"
          email: "amstilp@uw.edu"
    }
}
