--
-- Title:      Audit tables
-- Database:   PostgreSql
-- Since:      V3.2 Schema 3002
-- Author:     Pavel Yurkevich
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--

CREATE SEQUENCE alf_audit_model_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_audit_model
(
   id BIGINT NOT NULL,
   content_data_id BIGINT NOT NULL,
   content_crc BIGINT NOT NULL,   
   PRIMARY KEY (id)
);

CREATE UNIQUE INDEX idx_alf_aud_mod_cr ON alf_audit_model(content_crc);
CREATE INDEX fk_alf_aud_mod_cd ON alf_audit_model(content_data_id);
ALTER TABLE alf_audit_model ADD CONSTRAINT FOREIGN KEY (content_data_id) REFERENCES alf_content_data (id) CONSTRAINT fk_alf_aud_mod_cd;
ALTER TABLE alf_audit_model LOCK MODE(ROW);

CREATE SEQUENCE alf_audit_app_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_audit_app
(
   id BIGINT NOT NULL,
   version BIGINT NOT NULL,
   app_name_id BIGINT NOT NULL CONSTRAINT idx_alf_aud_app_an UNIQUE,
   audit_model_id BIGINT NOT NULL,
   disabled_paths_id BIGINT NOT NULL,
   PRIMARY KEY (id)
);
CREATE INDEX fk_alf_aud_app_mod ON alf_audit_app(audit_model_id);
CREATE INDEX fk_alf_aud_app_dis ON alf_audit_app(disabled_paths_id);
ALTER TABLE alf_audit_app ADD CONSTRAINT FOREIGN KEY (app_name_id) REFERENCES alf_prop_value (id) CONSTRAINT fk_alf_aud_app_an;
ALTER TABLE alf_audit_app ADD CONSTRAINT FOREIGN KEY (audit_model_id) REFERENCES alf_audit_model (id) ON DELETE CASCADE CONSTRAINT fk_alf_aud_app_mod;
ALTER TABLE alf_audit_app ADD CONSTRAINT FOREIGN KEY (disabled_paths_id) REFERENCES alf_prop_root (id) CONSTRAINT fk_alf_aud_app_dis;
ALTER TABLE alf_audit_app LOCK MODE(ROW);

CREATE SEQUENCE alf_audit_entry_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_audit_entry
(
   id BIGINT NOT NULL,
   audit_app_id BIGINT NOT NULL,
   audit_time BIGINT NOT NULL,
   audit_user_id BIGINT,
   audit_values_id BIGINT,
   PRIMARY KEY (id)
);
CREATE INDEX fk_alf_aud_ent_app ON alf_audit_entry(audit_app_id);
CREATE INDEX fk_alf_aud_ent_use ON alf_audit_entry(audit_user_id);
CREATE INDEX fk_alf_aud_ent_pro ON alf_audit_entry(audit_values_id);
ALTER TABLE alf_audit_entry ADD CONSTRAINT FOREIGN KEY (audit_app_id) REFERENCES alf_audit_app (id) ON DELETE CASCADE CONSTRAINT fk_alf_aud_ent_app;
ALTER TABLE alf_audit_entry ADD CONSTRAINT FOREIGN KEY (audit_user_id) REFERENCES alf_prop_value (id) CONSTRAINT fk_alf_aud_ent_use;
ALTER TABLE alf_audit_entry ADD CONSTRAINT FOREIGN KEY (audit_values_id) REFERENCES alf_prop_root (id) CONSTRAINT fk_alf_aud_ent_pro;
CREATE INDEX idx_alf_aud_ent_tm ON alf_audit_entry(audit_time);
ALTER TABLE alf_audit_entry LOCK MODE(ROW);


--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V3.2-AuditTables';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V3.2-AuditTables', 'Manually executed script upgrade V3.2: Audit Tables',
    0, 3001, -1, 3002, CURRENT, 'UNKOWN', ${TRUE}, ${TRUE}, 'Script completed'
  );