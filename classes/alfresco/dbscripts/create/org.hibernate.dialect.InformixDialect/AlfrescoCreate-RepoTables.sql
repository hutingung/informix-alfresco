--
-- Title:      Core Repository Tables
-- Database:   PostgreSQL
-- Since:      V3.3 Schema 4000
-- Author:     unknown
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--

CREATE TABLE alf_applied_patch
(
    id VARCHAR(64) NOT NULL,
    description LVARCHAR(1024),
    fixes_from_schema BIGINT,
    fixes_to_schema BIGINT,
    applied_to_schema BIGINT,
    target_schema BIGINT,
    applied_on_date datetime year to fraction(5),
    applied_to_server VARCHAR(64),
    was_executed SMALLINT,
    succeeded SMALLINT,
    report LVARCHAR(1024),
    PRIMARY KEY (id)
);

CREATE SEQUENCE alf_locale_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_locale
(
    id BIGINT NOT NULL,
    version BIGINT NOT NULL,
    locale_str VARCHAR(20) NOT NULL,
    PRIMARY KEY (id)    
);
CREATE UNIQUE INDEX locale_str ON alf_locale (locale_str);

ALTER TABLE alf_locale LOCK MODE(ROW);

CREATE SEQUENCE alf_namespace_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_namespace
(
    id BIGINT NOT NULL,
    version BIGINT NOT NULL,
    uri VARCHAR(100) NOT NULL,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX uri ON alf_namespace (uri);

CREATE SEQUENCE alf_qname_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_qname
(
    id BIGINT NOT NULL,
    version BIGINT NOT NULL,
    ns_id BIGINT NOT NULL,
    local_name VARCHAR(200) NOT NULL,
    PRIMARY KEY (id)
);

ALTER TABLE alf_qname ADD CONSTRAINT FOREIGN KEY (ns_id) REFERENCES alf_namespace (id) CONSTRAINT fk_alf_qname_ns;    
CREATE UNIQUE INDEX ns_id ON alf_qname (ns_id, local_name);

CREATE SEQUENCE alf_permission_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_permission
(
    id BIGINT NOT NULL,
    version BIGINT NOT NULL,
    type_qname_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    PRIMARY KEY (id)
);

CREATE INDEX fk_alf_perm_tqn ON alf_permission (type_qname_id);
ALTER TABLE alf_permission ADD CONSTRAINT FOREIGN KEY (type_qname_id) REFERENCES alf_qname (id) CONSTRAINT fk_alf_perm_tqn;
ALTER TABLE alf_permission LOCK MODE(ROW);

CREATE UNIQUE INDEX type_qname_id ON alf_permission (type_qname_id, name);

CREATE SEQUENCE alf_ace_context_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_ace_context
(
    id BIGINT NOT NULL,
    version BIGINT NOT NULL,
    class_context LVARCHAR(1024),
    property_context LVARCHAR(1024),
    kvp_context LVARCHAR(1024),
    PRIMARY KEY (id)
);

CREATE SEQUENCE alf_authority_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_authority
(
    id BIGINT NOT NULL,
    version BIGINT NOT NULL,
    authority VARCHAR(100),
    crc BIGINT,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX authority ON alf_authority (authority, crc);
CREATE INDEX idx_alf_auth_aut ON alf_authority (authority);

CREATE SEQUENCE alf_access_control_entry_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_access_control_entry
(
    id BIGINT NOT NULL,
    version BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    authority_id BIGINT NOT NULL,
    allowed BOOLEAN NOT NULL,
    applies BIGINT NOT NULL,
    context_id BIGINT,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX permission_id ON alf_access_control_entry (permission_id, authority_id, allowed, applies);
CREATE INDEX fk_alf_ace_ctx ON alf_access_control_entry (context_id);
CREATE INDEX fk_alf_ace_perm ON alf_access_control_entry (permission_id);
CREATE INDEX fk_alf_ace_auth ON alf_access_control_entry (authority_id);

ALTER TABLE alf_access_control_entry ADD CONSTRAINT FOREIGN KEY (authority_id) REFERENCES alf_authority (id) CONSTRAINT fk_alf_ace_auth;
ALTER TABLE alf_access_control_entry ADD CONSTRAINT FOREIGN KEY (context_id) REFERENCES alf_ace_context (id) CONSTRAINT fk_alf_ace_ctx;
ALTER TABLE alf_access_control_entry ADD CONSTRAINT FOREIGN KEY (permission_id) REFERENCES alf_permission (id) CONSTRAINT fk_alf_ace_perm;


CREATE SEQUENCE alf_acl_change_set_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_acl_change_set
(
    id BIGINT NOT NULL,
    commit_time_ms BIGINT,
    PRIMARY KEY (id)
);
CREATE INDEX idx_alf_acs_ctms ON alf_acl_change_set (commit_time_ms);

CREATE SEQUENCE alf_access_control_list_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_access_control_list
(
    id BIGINT NOT NULL,
    version BIGINT NOT NULL,
    acl_id VARCHAR(36)  NOT NULL,
    latest BOOLEAN NOT NULL,
    acl_version BIGINT NOT NULL,
    inherits BOOLEAN NOT NULL,
    inherits_from BIGINT,
    type BIGINT NOT NULL,
    inherited_acl BIGINT,
    is_versioned BOOLEAN NOT NULL,
    requires_version BOOLEAN NOT NULL,
    acl_change_set BIGINT,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX acl_id ON alf_access_control_list (acl_id, latest, acl_version);
CREATE INDEX idx_alf_acl_inh ON alf_access_control_list (inherits, inherits_from);
CREATE INDEX fk_alf_acl_acs ON alf_access_control_list (acl_change_set);
ALTER TABLE alf_access_control_list ADD CONSTRAINT FOREIGN KEY (acl_change_set) REFERENCES alf_acl_change_set (id) CONSTRAINT fk_alf_acl_acs;

CREATE SEQUENCE alf_acl_member_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_acl_member
(
    id BIGINT NOT NULL,
    version BIGINT NOT NULL,
    acl_id BIGINT NOT NULL,
    ace_id BIGINT NOT NULL,
    pos BIGINT NOT NULL,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX aclm_acl_id ON alf_acl_member (acl_id, ace_id, pos);
CREATE INDEX fk_alf_aclm_acl ON alf_acl_member (acl_id);
CREATE INDEX fk_alf_aclm_ace ON alf_acl_member (ace_id);
ALTER TABLE alf_acl_member ADD CONSTRAINT FOREIGN KEY (ace_id) REFERENCES alf_access_control_entry (id) CONSTRAINT fk_alf_aclm_ace;
ALTER TABLE alf_acl_member ADD CONSTRAINT FOREIGN KEY (acl_id) REFERENCES alf_access_control_list (id) CONSTRAINT fk_alf_aclm_acl;

CREATE SEQUENCE alf_authority_alias_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_authority_alias
(
    id BIGINT NOT NULL,
    version BIGINT NOT NULL,
    auth_id BIGINT NOT NULL,
    alias_id BIGINT NOT NULL,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX auth_id ON alf_authority_alias (auth_id, alias_id);
CREATE INDEX fk_alf_autha_ali ON alf_authority_alias (alias_id);
CREATE INDEX fk_alf_autha_aut ON alf_authority_alias (auth_id);
ALTER TABLE alf_authority_alias ADD CONSTRAINT FOREIGN KEY (auth_id) REFERENCES alf_authority (id) CONSTRAINT fk_alf_autha_aut;
ALTER TABLE alf_authority_alias ADD CONSTRAINT FOREIGN KEY (alias_id) REFERENCES alf_authority (id) CONSTRAINT fk_alf_autha_ali;

CREATE SEQUENCE alf_server_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_server
(
    id BIGINT NOT NULL,
    version BIGINT NOT NULL,
    ip_address VARCHAR(39) NOT NULL,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX ip_address ON alf_server (ip_address);

CREATE SEQUENCE alf_transaction_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_transaction
(
    id BIGINT NOT NULL,
    version BIGINT NOT NULL,
    server_id BIGINT,
    change_txn_id VARCHAR(56) NOT NULL,
    commit_time_ms BIGINT,
    PRIMARY KEY (id)
);

CREATE INDEX idx_alf_txn_ctms ON alf_transaction (commit_time_ms, id);
CREATE INDEX fk_alf_txn_svr ON alf_transaction (server_id);
ALTER TABLE alf_transaction ADD CONSTRAINT FOREIGN KEY (server_id) REFERENCES alf_server (id) CONSTRAINT fk_alf_txn_svr;
ALTER TABLE alf_transaction LOCK MODE (ROW);


CREATE SEQUENCE alf_store_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_store
(
    id BIGINT NOT NULL,
    version BIGINT NOT NULL,
    protocol VARCHAR(50) NOT NULL,
    identifier VARCHAR(100) NOT NULL,
    root_node_id BIGINT,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX protocol ON alf_store (protocol, identifier);
ALTER TABLE alf_store LOCK MODE (ROW);

CREATE SEQUENCE alf_node_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_node
(
    id BIGINT NOT NULL,
    version BIGINT NOT NULL,
    store_id BIGINT NOT NULL,
    uuid VARCHAR(36) NOT NULL,
    transaction_id BIGINT NOT NULL,
    type_qname_id BIGINT NOT NULL,
    locale_id BIGINT NOT NULL,
    acl_id BIGINT,
    audit_creator VARCHAR(255),
    audit_created VARCHAR(30),
    audit_modifier VARCHAR(255),
    audit_modified VARCHAR(30),
    audit_accessed VARCHAR(30),
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX store_id ON alf_node (store_id, uuid);
CREATE INDEX idx_alf_node_mdq ON alf_node (store_id, type_qname_id, id);
CREATE INDEX idx_alf_node_cor ON alf_node (audit_creator, store_id, type_qname_id, id);
CREATE INDEX idx_alf_node_crd ON alf_node (audit_created, store_id, type_qname_id, id);
CREATE INDEX idx_alf_node_mor ON alf_node (audit_modifier, store_id, type_qname_id, id);
CREATE INDEX idx_alf_node_mod ON alf_node (audit_modified, store_id, type_qname_id, id);
CREATE INDEX idx_alf_node_txn_type ON alf_node (transaction_id, type_qname_id);
CREATE INDEX fk_alf_node_acl ON alf_node (acl_id);
CREATE INDEX fk_alf_node_store ON alf_node (store_id);
CREATE INDEX fk_alf_node_tqn ON alf_node (type_qname_id);
CREATE INDEX fk_alf_node_loc ON alf_node (locale_id);
CREATE INDEX fk_alf_store_root ON alf_store (root_node_id);

ALTER TABLE alf_node ADD CONSTRAINT FOREIGN KEY (acl_id) REFERENCES alf_access_control_list (id) CONSTRAINT fk_alf_node_acl;
ALTER TABLE alf_node ADD CONSTRAINT FOREIGN KEY (store_id) REFERENCES alf_store (id) CONSTRAINT fk_alf_node_store;
ALTER TABLE alf_node ADD CONSTRAINT FOREIGN KEY (type_qname_id) REFERENCES alf_qname (id) CONSTRAINT fk_alf_node_tqn;
ALTER TABLE alf_node ADD CONSTRAINT FOREIGN KEY (transaction_id) REFERENCES alf_transaction (id) CONSTRAINT fk_alf_node_txn;
ALTER TABLE alf_node ADD CONSTRAINT FOREIGN KEY (locale_id) REFERENCES alf_locale (id) CONSTRAINT fk_alf_node_loc;

--Changed locking strategy
ALTER TABLE alf_node LOCK MODE (ROW);

ALTER TABLE alf_store ADD CONSTRAINT FOREIGN KEY (root_node_id) REFERENCES alf_node (id) CONSTRAINT fk_alf_store_root;

CREATE SEQUENCE alf_child_assoc_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_child_assoc
(
    id BIGINT NOT NULL,
    version BIGINT NOT NULL,
    parent_node_id BIGINT NOT NULL,
    type_qname_id BIGINT NOT NULL,
    child_node_name_crc BIGINT NOT NULL,
    child_node_name VARCHAR(50) NOT NULL,
    child_node_id BIGINT NOT NULL,
    qname_ns_id BIGINT NOT NULL,
    qname_localname VARCHAR(255) NOT NULL,
    qname_crc BIGINT NOT NULL,
    is_primary BOOLEAN,
    assoc_index BIGINT,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX parent_node_id ON alf_child_assoc (parent_node_id, type_qname_id, child_node_name_crc, child_node_name);
CREATE INDEX idx_alf_cass_pnode ON alf_child_assoc (parent_node_id, assoc_index, id);
CREATE INDEX fk_alf_cass_cnode ON alf_child_assoc (child_node_id);
CREATE INDEX fk_alf_cass_tqn ON alf_child_assoc (type_qname_id);
CREATE INDEX fk_alf_cass_qnns ON alf_child_assoc (qname_ns_id);
CREATE INDEX idx_alf_cass_qncrc ON alf_child_assoc (qname_crc, type_qname_id, parent_node_id);
CREATE INDEX idx_alf_cass_pri ON alf_child_assoc (parent_node_id, is_primary, child_node_id);
ALTER TABLE alf_child_assoc ADD CONSTRAINT FOREIGN KEY (child_node_id) REFERENCES alf_node (id) CONSTRAINT fk_alf_cass_cnode;
ALTER TABLE alf_child_assoc ADD CONSTRAINT FOREIGN KEY (parent_node_id) REFERENCES alf_node (id) CONSTRAINT fk_alf_cass_pnode;
ALTER TABLE alf_child_assoc ADD CONSTRAINT FOREIGN KEY (qname_ns_id) REFERENCES alf_namespace (id) CONSTRAINT fk_alf_cass_qnns;
ALTER TABLE alf_child_assoc ADD CONSTRAINT FOREIGN KEY (type_qname_id) REFERENCES alf_qname (id) CONSTRAINT fk_alf_cass_tqn;
ALTER TABLE alf_child_assoc LOCK MODE(ROW);

CREATE TABLE alf_node_aspects
(
    node_id BIGINT NOT NULL,
    qname_id BIGINT NOT NULL,
    PRIMARY KEY (node_id, qname_id)
);
CREATE INDEX fk_alf_nasp_n ON alf_node_aspects (node_id);
CREATE INDEX fk_alf_nasp_qn ON alf_node_aspects (qname_id);
ALTER TABLE alf_node_aspects ADD CONSTRAINT FOREIGN KEY (node_id) REFERENCES alf_node (id) CONSTRAINT fk_alf_nasp_n;
ALTER TABLE alf_node_aspects ADD CONSTRAINT FOREIGN KEY (qname_id) REFERENCES alf_qname (id) CONSTRAINT fk_alf_nasp_qn;
ALTER TABLE alf_node_aspects LOCK MODE(ROW);

CREATE SEQUENCE alf_node_assoc_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_node_assoc
(
    id BIGINT NOT NULL,
    version BIGINT NOT NULL,
    source_node_id BIGINT NOT NULL,
    target_node_id BIGINT NOT NULL,
    type_qname_id BIGINT NOT NULL,
    assoc_index BIGINT NOT NULL,
    PRIMARY KEY (id)
);

    
CREATE UNIQUE INDEX source_node_id ON alf_node_assoc (source_node_id, target_node_id, type_qname_id);
CREATE INDEX fk_alf_nass_snode ON alf_node_assoc (source_node_id, type_qname_id, assoc_index);
CREATE INDEX fk_alf_nass_tnode ON alf_node_assoc (target_node_id, type_qname_id);
CREATE INDEX fk_alf_nass_tqn ON alf_node_assoc (type_qname_id);
ALTER TABLE alf_node_assoc ADD CONSTRAINT FOREIGN KEY (source_node_id) REFERENCES alf_node (id) CONSTRAINT fk_alf_nass_snode;
ALTER TABLE alf_node_assoc ADD CONSTRAINT FOREIGN KEY (target_node_id) REFERENCES alf_node (id) CONSTRAINT fk_alf_nass_tnode;
ALTER TABLE alf_node_assoc ADD CONSTRAINT FOREIGN KEY (type_qname_id) REFERENCES alf_qname (id) CONSTRAINT fk_alf_nass_tqn;
ALTER TABLE alf_node_assoc LOCK MODE(ROW);

CREATE TABLE alf_node_properties
(
    node_id BIGINT NOT NULL,
    actual_type_n BIGINT NOT NULL,
    persisted_type_n BIGINT NOT NULL,
    boolean_value BOOLEAN,
    long_value BIGINT,
    float_value FLOAT,
    double_value FLOAT,
    string_value LVARCHAR(1024),
    serializable_value BYTE,
    qname_id BIGINT NOT NULL,
    list_index BIGINT NOT NULL,
    locale_id BIGINT NOT NULL,
    PRIMARY KEY (node_id, qname_id, list_index, locale_id)
);

CREATE INDEX fk_alf_nprop_n ON alf_node_properties (node_id);
CREATE INDEX fk_alf_nprop_qn ON alf_node_properties (qname_id);
CREATE INDEX fk_alf_nprop_loc ON alf_node_properties (locale_id);
--CREATE INDEX idx_alf_nprop_s ON alf_node_properties (qname_id, string_value, node_id);
CREATE INDEX idx_alf_nprop_l ON alf_node_properties (qname_id, long_value, node_id);
ALTER TABLE alf_node_properties ADD CONSTRAINT FOREIGN KEY (locale_id) REFERENCES alf_locale (id) CONSTRAINT fk_alf_nprop_loc;
ALTER TABLE alf_node_properties ADD CONSTRAINT FOREIGN KEY (node_id) REFERENCES alf_node (id) CONSTRAINT fk_alf_nprop_n;
ALTER TABLE alf_node_properties ADD CONSTRAINT FOREIGN KEY (qname_id) REFERENCES alf_qname (id) CONSTRAINT fk_alf_nprop_q;
ALTER TABLE alf_node_properties LOCK MODE(ROW);
