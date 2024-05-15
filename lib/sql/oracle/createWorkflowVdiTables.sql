CREATE TABLE apidb.WorkflowArtifactVdiId (
vdi_id                varchar2(32)  PRIMARY KEY NOT NULL,
workflow_name         varchar2(30)  NOT NULL,
workflow_version      varchar2(30)  NOT NULL,
artifact_name         varchar2(200) NOT NULL,
organism_abbrev       varchar2(30),
artifact_timestamp    number        NOT NULL,
is_complete           number        NOT NULL
);

ALTER TABLE apidb.WorkflowArtifactVdiId
ADD CONSTRAINT wavi_uniq
UNIQUE (workflow_name, workflow_version, artifact_name, organism_abbrev);

GRANT insert, select, update, delete ON ApiDB.WorkflowArtifactVdiId TO gus_w;
GRANT select ON ApiDB.WorkflowArtifactVdiId TO gus_r;



exit;



