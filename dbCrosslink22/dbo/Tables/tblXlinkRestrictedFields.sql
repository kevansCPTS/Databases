CREATE TABLE [dbo].[tblXlinkRestrictedFields] (
    [restricted_id]    INT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [create_date]      DATETIME    NULL,
    [update_date]      DATETIME    NULL,
    [publish_date]     DATETIME    NULL,
    [restricted_field] VARCHAR (8) NULL,
    [account_id]       VARCHAR (8) NULL,
    [user_id]          INT         NULL,
    [franchiseuser_id] INT         NULL,
    CONSTRAINT [PK_tblXlinkRestrictedFields] PRIMARY KEY CLUSTERED ([restricted_id] ASC),
    CONSTRAINT [UN_tblXlinkRestrictedFields] UNIQUE NONCLUSTERED ([restricted_field] ASC, [user_id] ASC, [account_id] ASC, [franchiseuser_id] ASC)
);

