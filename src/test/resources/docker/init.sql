-- SCHEMA CREATION

CREATE TABLE AccessTag
(
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(255) NULL,
    name        VARCHAR(255) NULL,
    CONSTRAINT AccessTag_name_idx UNIQUE (name)
);

CREATE TABLE Counter
(
    id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    maxCount BIGINT NOT NULL,
    name     VARCHAR(255) NULL,
    CONSTRAINT Counter_name_idx UNIQUE (name)
);

CREATE TABLE IdGen
(
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    prefix     VARCHAR(255) NULL,
    suffix     VARCHAR(255) NULL,
    counter_id BIGINT NULL,
    CONSTRAINT pfxsfx_idx UNIQUE (prefix, suffix),
    CONSTRAINT IdGen_Counter_FRG_KEY FOREIGN KEY (counter_id) REFERENCES Counter (id)
);

CREATE INDEX FKjndkokb5qh9p1af7cim617rvv ON IdGen (counter_id);

CREATE TABLE ElementTag
(
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(255) NOT NULL,
    classifier VARCHAR(255) NOT NULL,
    CONSTRAINT tag_name UNIQUE (classifier, name)
);

CREATE TABLE SubmissionRT
(
    id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    accNo    LONGTEXT NOT NULL,
    ticketId LONGTEXT NOT NULL
);

-- Security
CREATE TABLE User
(
    id                   BIGINT AUTO_INCREMENT PRIMARY KEY,
    activationKey        VARCHAR(255) NULL,
    active               BIT    NOT NULL,
    orcid                VARCHAR(255) NULL,
    email                VARCHAR(255) NULL,
    fullName             VARCHAR(255) NULL,
    keyTime              BIGINT NOT NULL,
    login                VARCHAR(255) NULL,
    passwordDigest       LONGBLOB NULL,
    secret               VARCHAR(255) NULL,
    superuser            BIT    NOT NULL,
    ssoSubject           VARCHAR(255) NULL,
    notificationsEnabled BIT    NOT NULL,
    CONSTRAINT email_index UNIQUE (email),
    CONSTRAINT login_index UNIQUE (login)
);


CREATE TABLE UserData
(
    dataKey     VARCHAR(255) NOT NULL,
    userId      BIGINT       NOT NULL,
    data        LONGTEXT NULL,
    contentType VARCHAR(255) NULL,
    topic       VARCHAR(255) NULL,
    PRIMARY KEY (dataKey, userId)
);

CREATE TABLE UserGroup
(
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(255) NULL,
    name        VARCHAR(255) NULL,
    owner_id    BIGINT NULL,
    secret      VARCHAR(255) NULL,
    CONSTRAINT UserGroup_name_IDX UNIQUE (name),
    CONSTRAINT UserGroup_OwnerId_FRG_KEY FOREIGN KEY (owner_id) REFERENCES User (id)
);

CREATE INDEX UserGroup_owner_id_IDX ON UserGroup (owner_id);

CREATE TABLE UserGroup_User
(
    groups_id BIGINT NOT NULL,
    users_id  BIGINT NOT NULL,
    CONSTRAINT UserGroup_User_FRG_KEY FOREIGN KEY (groups_id) REFERENCES UserGroup (id),
    CONSTRAINT User_UserGroup_FRG_KEY FOREIGN KEY (users_id) REFERENCES User (id)
);

CREATE INDEX UserGroup_User_UserId_IDX ON UserGroup_User (users_id);
CREATE INDEX UserGroup_User_GroupId_IDX ON UserGroup_User (groups_id);

CREATE TABLE UserGroup_UserGroup
(
    UserGroup_id BIGINT NOT NULL,
    groups_id    BIGINT NOT NULL,
    CONSTRAINT UserGroup_UserGroup_UserGroupId_FRG_KEY FOREIGN KEY (UserGroup_id) REFERENCES UserGroup (id),
    CONSTRAINT UserGroup_UserGroup_Group_id_FRG_KEY FOREIGN KEY (groups_id) REFERENCES UserGroup (id)
);

CREATE INDEX UserGroup_UserGroup_GroupId_IDX ON UserGroup_UserGroup (groups_id);
CREATE INDEX UserGroup_UserGroup_UserGroupId_IDX ON UserGroup_UserGroup (UserGroup_id);

CREATE TABLE AccessPermission
(
    id            BIGINT PRIMARY KEY AUTO_INCREMENT,
    access_type   VARCHAR(255),
    user_id       BIGINT NOT NULL,
    access_tag_id BIGINT NOT NULL
);

ALTER TABLE AccessPermission
    ADD CONSTRAINT access_permission_user_fk FOREIGN KEY (user_id) REFERENCES User (id);
ALTER TABLE AccessPermission
    ADD CONSTRAINT access_permission_access_tag_fk
        FOREIGN KEY (access_tag_id) REFERENCES AccessTag (id);

CREATE UNIQUE INDEX access_permission_id_index ON AccessPermission (id);

CREATE TABLE SecurityToken
(
    id                VARCHAR(500) PRIMARY KEY NOT NULL,
    invalidation_date DATETIME                 NOT NULL
);
CREATE UNIQUE INDEX SecurityToken_id_uindex ON SecurityToken (id);

-- INITIAL USERS INSERTIONS

INSERT INTO User (
    activationKey,
    active,
    orcid,
    email,
    fullName,
    keyTime,
    login,
    passwordDigest,
    secret,
    superuser,
    ssoSubject,
    notificationsEnabled)
VALUES (null, false, null, null, 'Anonymous user', 0, '@Guest', null, null, false, null, false),
       (null, false, null, null, 'Represents system owned objects', 0, '@System', null, null, false, null, false),
       (null, false, null, 'default_user@ebi.ac.uk', 'Default User', 0, '@Default', null, null, false, null, false),
       (null,
        true,
        null,
        'admin_user@ebi.ac.uk',
        'Admin User',
        0,
        'admin_user',
        X'7C4A8D09CA3762AF61E59520943DC26494F8941B',
        '69214a2f-f80b-4f33-86b7-26d3bd0453aa',
        true,
        null,
        false);

-- INITIAL ACCESS TAGS INSERTIONS

INSERT INTO AccessTag (id, description, name) VALUES (1, null, 'Public');
INSERT INTO AccessTag (id, description, name) VALUES (2, null, 'EuropePMC');

-- INITIAL SEQUENCES INSERTIONS

INSERT INTO Counter VALUES(1, -1, 'S-BSST000null');
INSERT INTO Counter VALUES(2, -1, 'S-EPMC000null');

INSERT INTO IdGen VALUES(1, 'S-BSST', '', 1);
INSERT INTO IdGen VALUES(2, 'S-EPMC', '', 2);

-- INITIAL PERMISSION INSERTION

INSERT INTO AccessPermission(access_type, user_id, access_tag_id) VALUES('ATTACH', 3, 2);
