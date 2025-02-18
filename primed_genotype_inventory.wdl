version 1.0

workflow primed_genotype_inventory {
    input {
        Map[String, String] workspaces
        String output_workspace_name
        String output_workspace_namespace
        String output_table
    }

    call write_primed_genotype_inventory_table {
        input: workspaces = workspaces,
                output_workspace_name = output_workspace_name,
                output_workspace_namespace = output_workspace_namespace,
                output_table = output_table
    }

    meta {
          author: "Adrienne stilp"
          email: "amstilp@uw.edu"
    }
}

task write_primed_genotype_inventory_table {
    input {
        Map[String, String] workspaces
        String output_workspace_name
        String output_workspace_namespace
        String output_table
    }

    command <<<
        set -e
        Rscript /usr/local/primed-inventory-workflows/write_primed_genotype_inventory_table.R \
            --workspaces-file ~{write_map(workspaces)} \
            --output-workspace-name ~{output_workspace_name} \
            --output-workspace-namespace ~{output_workspace_namespace} \
            --output-table-name ~{output_table}
    >>>

    runtime {
        docker: "uwgac/primed-inventory-workflows:0.3.1"
    }
}
