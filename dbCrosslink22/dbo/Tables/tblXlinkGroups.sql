CREATE TABLE [dbo].[tblXlinkGroups] (
    [group_id]         INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [create_date]      DATETIME     CONSTRAINT [DF_tblXlinkGroups_create_date] DEFAULT (getdate()) NULL,
    [update_date]      DATETIME     CONSTRAINT [DF_tblXlinkGroups_update_date] DEFAULT (getdate()) NULL,
    [publish_date]     DATETIME     NULL,
    [group_name]       VARCHAR (20) NULL,
    [account_id]       VARCHAR (8)  NULL,
    [franchiseuser_id] INT          NULL,
    CONSTRAINT [PK_tblXlinkGroups] PRIMARY KEY CLUSTERED ([group_id] ASC)
);

