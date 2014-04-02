--
-- Title:      Property Value tables
-- Database:   PostgreSql
-- Since:      V3.2 Schema 3001
-- Author:     Pavel Yurkevich
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--

CREATE SEQUENCE alf_prop_class_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_prop_class
(
   id BIGINT NOT NULL,
   java_class_name VARCHAR(255) NOT NULL,
   java_class_name_short VARCHAR(32) NOT NULL,
   java_class_name_crc BIGINT NOT NULL,   
   PRIMARY KEY (id)
);
CREATE UNIQUE INDEX idx_alf_propc_crc ON alf_prop_class(java_class_name_crc, java_class_name_short);
CREATE INDEX idx_alf_propc_clas ON alf_prop_class(java_class_name);
ALTER TABLE alf_prop_class LOCK MODE(ROW);

CREATE TABLE alf_prop_date_value
(
   date_value BIGINT NOT NULL,
   full_year BIGINT NOT NULL,
   half_of_year BIGINT NOT NULL,
   quarter_of_year BIGINT NOT NULL,
   month_of_year BIGINT NOT NULL,
   week_of_year BIGINT NOT NULL,
   week_of_month BIGINT NOT NULL,
   day_of_year BIGINT NOT NULL,
   day_of_month BIGINT NOT NULL,
   day_of_week BIGINT NOT NULL,   
   PRIMARY KEY (date_value)
);
CREATE INDEX idx_alf_propdt_dt ON alf_prop_date_value(full_year, month_of_year, day_of_month);
ALTER TABLE alf_prop_date_value LOCK MODE(ROW);

CREATE SEQUENCE alf_prop_double_value_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_prop_double_value
(
   id BIGINT NOT NULL,
   double_value FLOAT NOT NULL,   
   PRIMARY KEY (id)
);
CREATE UNIQUE INDEX idx_alf_propd_val ON alf_prop_double_value(double_value);
ALTER TABLE alf_prop_double_value LOCK MODE(ROW);

-- Stores unique, case-sensitive string values --
CREATE SEQUENCE alf_prop_string_value_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_prop_string_value
(
   id BIGINT NOT NULL,
   string_value LVARCHAR(1024) NOT NULL,
   string_end_lower VARCHAR(16) NOT NULL,
   string_crc BIGINT NOT NULL,   
   PRIMARY KEY (id)
);
--TODO ERROR - the total size of the index is too large or too many parts in index
--CREATE INDEX idx_alf_props_str ON alf_prop_string_value(string_value);
CREATE UNIQUE INDEX idx_alf_props_crc ON alf_prop_string_value(string_end_lower, string_crc);
ALTER TABLE alf_prop_string_value LOCK MODE(ROW);

CREATE SEQUENCE alf_prop_serializable_value_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_prop_serializable_value
(
   id BIGINT NOT NULL,
   serializable_value BYTE NOT NULL,
   PRIMARY KEY (id)
);
ALTER TABLE alf_prop_serializable_value LOCK MODE(ROW);

CREATE SEQUENCE alf_prop_value_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_prop_value
(
   id BIGINT NOT NULL,
   actual_type_id BIGINT NOT NULL,
   persisted_type BIGINT NOT NULL,
   long_value BIGINT NOT NULL,   
   PRIMARY KEY (id)
);
CREATE INDEX idx_alf_propv_per ON alf_prop_value(persisted_type, long_value);
CREATE UNIQUE INDEX idx_alf_propv_act ON alf_prop_value(actual_type_id, long_value);
ALTER TABLE alf_prop_value LOCK MODE(ROW);

CREATE SEQUENCE alf_prop_root_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_prop_root
(
   id BIGINT NOT NULL,
   version BIGINT NOT NULL,
   PRIMARY KEY (id)
);
ALTER TABLE alf_prop_root LOCK MODE(ROW);

CREATE TABLE alf_prop_link
(
   root_prop_id BIGINT NOT NULL,
   prop_index BIGINT NOT NULL,
   contained_in BIGINT NOT NULL,
   key_prop_id BIGINT NOT NULL,
   value_prop_id BIGINT NOT NULL,
   PRIMARY KEY (root_prop_id, contained_in, prop_index)
);
CREATE INDEX fk_alf_propln_key ON alf_prop_link(key_prop_id);
CREATE INDEX fk_alf_propln_val ON alf_prop_link(value_prop_id);

ALTER TABLE alf_prop_link ADD CONSTRAINT FOREIGN KEY (root_prop_id) REFERENCES alf_prop_root (id) ON DELETE CASCADE CONSTRAINT fk_alf_propln_root;
ALTER TABLE alf_prop_link ADD CONSTRAINT FOREIGN KEY (key_prop_id) REFERENCES alf_prop_value (id) ON DELETE CASCADE CONSTRAINT fk_alf_propln_key;
ALTER TABLE alf_prop_link ADD CONSTRAINT FOREIGN KEY (value_prop_id) REFERENCES alf_prop_value (id) ON DELETE CASCADE CONSTRAINT fk_alf_propln_val;   
CREATE INDEX idx_alf_propln_for ON alf_prop_link(root_prop_id, key_prop_id, value_prop_id);
ALTER TABLE alf_prop_link LOCK MODE(ROW);

CREATE SEQUENCE alf_prop_unique_ctx_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_prop_unique_ctx
(
   id BIGINT NOT NULL,
   version BIGINT NOT NULL,
   value1_prop_id BIGINT NOT NULL,
   value2_prop_id BIGINT NOT NULL,
   value3_prop_id BIGINT NOT NULL,
   prop1_id BIGINT,
   PRIMARY KEY (id)
);
CREATE INDEX fk_alf_propuctx_v2 ON alf_prop_unique_ctx(value2_prop_id);
CREATE INDEX fk_alf_propuctx_v3 ON alf_prop_unique_ctx(value3_prop_id);
CREATE INDEX fk_alf_propuctx_p1 ON alf_prop_unique_ctx(prop1_id);

ALTER TABLE alf_prop_unique_ctx ADD CONSTRAINT FOREIGN KEY (value1_prop_id) REFERENCES alf_prop_value (id) ON DELETE CASCADE CONSTRAINT fk_alf_propuctx_v1;
ALTER TABLE alf_prop_unique_ctx ADD CONSTRAINT FOREIGN KEY (value2_prop_id) REFERENCES alf_prop_value (id) ON DELETE CASCADE CONSTRAINT fk_alf_propuctx_v2;
ALTER TABLE alf_prop_unique_ctx ADD CONSTRAINT FOREIGN KEY (value3_prop_id) REFERENCES alf_prop_value (id) ON DELETE CASCADE CONSTRAINT fk_alf_propuctx_v3;
ALTER TABLE alf_prop_unique_ctx ADD CONSTRAINT FOREIGN KEY (prop1_id) REFERENCES alf_prop_root (id) CONSTRAINT fk_alf_propuctx_p1;
CREATE UNIQUE INDEX idx_alf_propuctx ON alf_prop_unique_ctx(value1_prop_id, value2_prop_id, value3_prop_id);
ALTER TABLE alf_prop_unique_ctx LOCK MODE(ROW);

--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V3.2-PropertyValueTables';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V3.2-PropertyValueTables', 'Manually executed script upgrade V3.2: PropertyValue Tables',
    0, 3000, -1, 3001, CURRENT, 'UNKOWN', ${TRUE}, ${TRUE}, 'Script completed'
  );