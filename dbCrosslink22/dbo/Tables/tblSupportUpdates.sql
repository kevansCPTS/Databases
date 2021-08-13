CREATE TABLE [dbo].[tblSupportUpdates] (
    [update_id]   INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [type]        VARCHAR (20)  NULL,
    [issue]       VARCHAR (100) NULL,
    [date]        VARCHAR (50)  NULL,
    [html]        VARCHAR (MAX) NULL,
    [iphone]      VARCHAR (MAX) NULL,
    [active]      BIT           CONSTRAINT [DF_tblSupportUpdates_active] DEFAULT ((1)) NULL,
    [create_date] DATETIME      CONSTRAINT [DF_tblSupportUpdates_create_date] DEFAULT (getdate()) NULL,
    [start_date]  DATETIME      CONSTRAINT [DF_tblSupportUpdates_start_date] DEFAULT (getdate()) NULL,
    [end_date]    DATETIME      NULL,
    CONSTRAINT [PK_tblSupportUpdates] PRIMARY KEY CLUSTERED ([update_id] ASC)
);

