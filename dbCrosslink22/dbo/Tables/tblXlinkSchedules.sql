CREATE TABLE [dbo].[tblXlinkSchedules] (
    [schedule_id]      INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [schedule_seqno]   INT          NOT NULL,
    [create_date]      DATETIME     CONSTRAINT [DF_tblXlinkSchedules_create_date] DEFAULT (getdate()) NULL,
    [update_date]      DATETIME     CONSTRAINT [DF_tblXlinkSchedules_update_date] DEFAULT (getdate()) NULL,
    [publish_date]     DATETIME     NULL,
    [schedule_name]    VARCHAR (20) NULL,
    [account_id]       VARCHAR (8)  NULL,
    [franchiseuser_id] INT          NULL,
    [schedule_type]    CHAR (1)     NULL,
    CONSTRAINT [PK_tblXlinkSchedules] PRIMARY KEY CLUSTERED ([schedule_id] ASC, [schedule_seqno] ASC)
);

