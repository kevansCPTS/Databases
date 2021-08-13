CREATE TABLE [dbo].[tblXlinkUserStatusCodes] (
    [status_id]          INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [create_date]        DATETIME     CONSTRAINT [DF_tblXlinkUserStatusCodes_create_date] DEFAULT (getdate()) NULL,
    [update_date]        DATETIME     CONSTRAINT [DF_tblXlinkUserStatusCodes_update_date] DEFAULT (getdate()) NULL,
    [publish_date]       DATETIME     NULL,
    [account_id]         VARCHAR (8)  NULL,
    [user_id]            INT          NULL,
    [status_code]        VARCHAR (7)  NOT NULL,
    [status_description] VARCHAR (35) NOT NULL,
    [franchiseuser_id]   INT          NULL,
    CONSTRAINT [PK_tblXlinkUserStatusCodes] PRIMARY KEY CLUSTERED ([status_id] ASC)
);

