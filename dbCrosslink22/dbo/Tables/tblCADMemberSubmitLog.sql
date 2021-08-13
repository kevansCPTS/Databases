CREATE TABLE [dbo].[tblCADMemberSubmitLog] (
    [logId]   INT           IDENTITY (1, 1) NOT NULL,
    [logData] VARCHAR (MAX) NULL,
    [logDate] DATETIME      NULL
);

