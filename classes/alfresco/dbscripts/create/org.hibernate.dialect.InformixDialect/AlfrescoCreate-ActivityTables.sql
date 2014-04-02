--
-- Title:      Activity tables
-- Database:   PostgreSQL
-- Since:      V3.0 Schema 126
-- Author:     janv
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--

CREATE SEQUENCE alf_activity_feed_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_activity_feed
(
    id BIGINT NOT NULL,
    post_id BIGINT,
    post_date datetime year to fraction(5) NOT NULL,
    activity_summary LVARCHAR(1024),
    feed_user_id VARCHAR(255),
    activity_type VARCHAR(255) NOT NULL,
    site_network VARCHAR(255),
    app_tool VARCHAR(36),
    post_user_id VARCHAR(255) NOT NULL,
    feed_date datetime year to fraction(5) NOT NULL,
    PRIMARY KEY (id)
);
CREATE INDEX feed_postdate_idx ON alf_activity_feed (post_date);
CREATE INDEX feed_postuserid_idx ON alf_activity_feed (post_user_id);
CREATE INDEX feed_feeduserid_idx ON alf_activity_feed (feed_user_id);
CREATE INDEX feed_sitenetwork_idx ON alf_activity_feed (site_network);
ALTER TABLE alf_activity_feed LOCK MODE(ROW);

CREATE SEQUENCE alf_activity_feed_control_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_activity_feed_control
(
    id BIGINT NOT NULL,
    feed_user_id VARCHAR(255) NOT NULL,
    site_network VARCHAR(255),
    app_tool VARCHAR(36),
    last_modified datetime year to fraction(5) NOT NULL,
    PRIMARY KEY (id)    
);
CREATE INDEX feedctrl_feeduserid_idx ON alf_activity_feed_control (feed_user_id);
ALTER TABLE alf_activity_feed_control LOCK MODE(ROW);

CREATE SEQUENCE alf_activity_post_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE alf_activity_post
(
    sequence_id BIGINT NOT NULL,
    post_date datetime year to fraction(5) NOT NULL,
    status VARCHAR(10) NOT NULL,
    activity_data LVARCHAR(1024) NOT NULL,
    post_user_id VARCHAR(255) NOT NULL,
    job_task_node BIGINT NOT NULL,
    site_network VARCHAR(255),
    app_tool VARCHAR(36),
    activity_type VARCHAR(255) NOT NULL,
    last_modified datetime year to fraction(5) NOT NULL,
    PRIMARY KEY (sequence_id)
);
CREATE INDEX post_jobtasknode_idx ON alf_activity_post (job_task_node);
CREATE INDEX post_status_idx ON alf_activity_post (status);
ALTER TABLE alf_activity_post LOCK MODE(ROW);

--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V3.0-ActivityTables';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V3.0-ActivityTables', 'Manually executed script upgrade V3.0: Activity Tables',
    0, 125, -1, 126, CURRENT, 'UNKNOWN', ${TRUE}, ${TRUE}, 'Script completed'
  );