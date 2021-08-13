CREATE TABLE [dbo].[tblXlinkAccessSets] (
    [set_id]           INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [create_date]      DATETIME     CONSTRAINT [DF_tblXlinkAccessSets_create_date] DEFAULT (getdate()) NULL,
    [update_date]      DATETIME     CONSTRAINT [DF_tblXlinkAccessSets_update_date] DEFAULT (getdate()) NULL,
    [publish_date]     DATETIME     NULL,
    [set_name]         VARCHAR (20) NULL,
    [account_id]       VARCHAR (8)  NULL,
    [franchiseuser_id] INT          NULL,
    CONSTRAINT [PK_tblXlinkAccessSets] PRIMARY KEY CLUSTERED ([set_id] ASC),
    CONSTRAINT [UN_tblXlinkAccessSets] UNIQUE NONCLUSTERED ([set_name] ASC, [account_id] ASC, [franchiseuser_id] ASC)
);

