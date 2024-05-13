#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//---------------------------------------------------------------------------------
// initial Param checking and Channels from input files
//---------------------------------------------------------------------------------
reflowManagerConfigFileChannel = Channel.fromPath(params.reflowManagerConfigFile, type: "file", checkIfExists: true).first()

sourceConfigFileChannel = Channel.value("READY!")
if(params.artifactType == "rdbms-table") {
    sourceConfigFileChannel = Channel.fromPath(params.sourceConfigFile, type: "file", checkIfExists: true).first()
}

if(params.workflowName == "NA") {
    throw new Exception("missing params.workflowName");
}

if(params.workflowVersion == "NA") {
    throw new Exception("missing params.workflowVersion");
}

if(params.artifactType != "rdbms-table"  && params.artifactType != "file" ) {
    throw new Exception("params.artifactType must be either rdbms-table or file");
}



//---------------------------------------------------------------------------------
// Includes
//---------------------------------------------------------------------------------
include { tuningTablesComparedToVdi; tuningTablesToArtifacts } from './modules/tuningTables.nf'


def splitCsvFile(csvPath, chunkSize) {
    return csvPath.splitText(by: chunkSize, file: true)
}

def flattenAndCollate(a, groupSize) {
    return a.flatten().collate(groupSize)
}

workflow tuningTablesOrViews {
    ttToVdiOut = tuningTablesComparedToVdi(reflowManagerConfigFileChannel, sourceConfigFileChannel)
    artifacts = tuningTablesToArtifacts(splitCsvFile(ttToVdiOut.needs_update, params.groupSizeForTuningTableDump), sourceConfigFileChannel)

    deleteFromVdiOut = workflowArtifactsDeleteFromVdi(splitCsvFile(ttToVdiOut.needs_delete, params.groupSizeForDelete))
    workflowArtifactToVdi(deleteFromVdiOut, flattenAndCollate(artifacts, params.groupSizeForSendArtifacts), reflowManagerConfigFileChannel)
}

process workflowArtifactsDeleteFromVdi {
  input:
    path artifactsToDelete

  output:
    stdout

  script:
    """
    # TODO
    #workflowArtifactsDeleteFromVdi --artifactsToDeleteFile $artifactsToDelete
    echo "Finished workflowArtifactsDeleteFromVdi!"
    """

  stub:
    """
    echo "Finished workflowArtifactsDeleteFromVdi!"
    """

}


process workflowArtifactToVdi {
  input:
    stdin
    path zipFiles
    path reflowManagerConfigFile

  output:
    stdout

  script:
    """
    for z in *.zip;
     do
       workflowArtifactToVdi --zipFile \$z \
        --reflowManagerConfigFile $reflowManagerConfigFile \
        --vdiServiceUrl $params.vdiServiceUrl \
        --organismAbbrev $params.organismAbbrev \
        --targetProjectName $params.targetProjectName \
        --vdiDataType $params.artifactType
    done;
    """

  stub:
    """
    for z in *.zip; do echo "processed zip file \$z"; done;
    """

}
