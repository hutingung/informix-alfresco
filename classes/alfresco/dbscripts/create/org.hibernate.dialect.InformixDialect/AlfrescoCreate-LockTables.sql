--
-- Title:      Create lock tables
-- Database:   PostgreSQL
-- Since:      V3.2 Schema 2011
-- Author:     
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--

CREATE SEQUENCE alf_lock_resource_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_lock_resource
(
   id BIGINT NOT NULL,
   version BIGINT NOT NULL,
   qname_ns_id BIGINT NOT NULL,
   qname_localname VARCHAR(255) NOT NULL,
   PRIMARY KEY (id)   
);
ALTER TABLE alf_lock_resource ADD CONSTRAINT FOREIGN KEY (qname_ns_id) REFERENCES alf_namespace (id) CONSTRAINT fk_alf_lockr_ns;
ALTER TABLE alf_lock_resource LOCK MODE(ROW);
   
CREATE UNIQUE INDEX idx_alf_lockr_key ON alf_lock_resource (qname_ns_id, qname_localname);

CREATE SEQUENCE alf_lock_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_lock
(
   id BIGINT NOT NULL,
   version BIGINT NOT NULL,
   shared_resource_id BIGINT NOT NULL,
   excl_resource_id BIGINT NOT NULL,
   lock_token VARCHAR(36) NOT NULL,
   start_time BIGINT NOT NULL,
   expiry_time BIGINT NOT NULL,
   PRIMARY KEY (id)
);
CREATE INDEX fk_alf_lock_excl ON alf_lock (excl_resource_id);

ALTER TABLE alf_lock ADD CONSTRAINT FOREIGN KEY (shared_resource_id) REFERENCES alf_lock_resource (id) CONSTRAINT fk_alf_lock_shared;
ALTER TABLE alf_lock ADD CONSTRAINT FOREIGN KEY (excl_resource_id) REFERENCES alf_lock_resource (id) CONSTRAINT fk_alf_lock_excl;
CREATE UNIQUE INDEX idx_alf_lock_key ON alf_lock (shared_resource_id, excl_resource_id);
ALTER TABLE alf_lock LOCK MODE(ROW);

--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V3.2-LockTables';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V3.2-LockTables', 'Manually executed script upgrade V3.2: Lock Tables',
    0, 2010, -1, 2011, CURRENT, 'UNKOWN', ${TRUE}, ${TRUE}, 'Script completed'
  );