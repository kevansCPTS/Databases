CREATE TABLE [dbo].[tblXlinkRestrictedForms] (
    [restricted_id]    INT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [create_date]      DATETIME    NULL,
    [update_date]      DATETIME    NULL,
    [publish_date]     DATETIME    NULL,
    [state_id]         CHAR (2)    NULL,
    [form_id]          VARCHAR (6) NULL,
    [restrict_add]     BIT         NULL,
    [restrict_edit]    BIT         NULL,
    [account_id]       VARCHAR (8) NULL,
    [user_id]          INT         NULL,
    [franchiseuser_id] INT         NULL,
    CONSTRAINT [PK_tblXlinkRestrictedForms] PRIMARY KEY CLUSTERED ([restricted_id] ASC),
    CONSTRAINT [UN_tblXlinkRestrictedForms] UNIQUE NONCLUSTERED ([form_id] ASC, [account_id] ASC, [user_id] ASC, [franchiseuser_id] ASC)
);

