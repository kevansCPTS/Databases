CREATE TABLE [dbo].[PortalLogging] (
    [LoggerID]  INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Pagename]  VARCHAR (50) NOT NULL,
    [IsLogging] BIT          CONSTRAINT [DF_PortalLogging_IsLogging] DEFAULT ((1)) NOT NULL,
    [editedBy]  VARCHAR (30) CONSTRAINT [DF_PortalLogging__editedBy] DEFAULT (original_login()) NOT NULL,
    [editDate]  DATETIME     CONSTRAINT [DF_PortalLogging__editDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PortalLogging] PRIMARY KEY CLUSTERED ([LoggerID] ASC)
);

