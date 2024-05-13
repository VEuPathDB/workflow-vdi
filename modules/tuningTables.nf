process tuningTablesComparedToVdi {
  input:
    path reflowManagerConfigFile
    path sourceConfigFile

  output:
    path 'needsUpdate.csv', emit: needs_update
    path 'needsDelete.csv', emit: needs_delete

  script:
    """
    # TODO
    #tuningTablesComparedToVdi --sourceConfigFile $sourceConfigFile \
    #        --reflowManagerConfigFile $reflowManagerConfigFile \
    #        --workflowName $params.workflowName \
    #        --workflowVersion $params.workflowVersion
    #        --needsUpdateOutputFile ./needsUpdate.csv
    #        --needsDeleteOutputFile ./needsDelete.csv
    """

  stub:
    """
    for i in {1..100}; do echo "updateArtifact\$i" >>needsUpdate.csv; done;
    for i in {1..25}; do echo "deleteArtifact\$i" >>needsDelete.csv; done;
    """
}



process tuningTablesToArtifacts {
  input:
    path needsUpdateFile
    path sourceConfigFile

  output:
    path '*.zip'


  script:
    """
    #TODO:  the needsUpdateFile can contain multiple rows.  make a directory and zip for each
    #tuningTablesToArtifacts --sourceConfigFile $sourceConfigFile \
        --needsUpdateFile $needsUpdateFile
    """

  stub:
    """
    cat $needsUpdateFile |while read l; do touch \$l.zip; done;
    """
}
