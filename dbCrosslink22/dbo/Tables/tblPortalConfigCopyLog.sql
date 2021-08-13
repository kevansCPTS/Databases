CREATE TABLE [dbo].[tblPortalConfigCopyLog] (
    [pccId]            INT      IDENTITY (1, 1) NOT NULL,
    [sourceUserId]     INT      NOT NULL,
    [targetUserId]     INT      NOT NULL,
    [targetArchiveXML] XML      NULL,
    [copyDate]         DATETIME CONSTRAINT [DF_tblPortalConfigCopyLog_copyDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblPortalConfigCopyLog] PRIMARY KEY CLUSTERED ([pccId] ASC)
);

