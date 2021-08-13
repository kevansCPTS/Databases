CREATE TABLE [dbo].[ReportTBAcks] (
    [ID]      INT IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Date]    INT NULL,
    [ACKs]    INT NULL,
    [Rejs]    INT NULL,
    [PChk]    INT NULL,
    [DD]      INT NULL,
    [RALs]    INT NULL,
    [BDue]    INT NULL,
    [RACs]    INT NULL,
    [Fees]    INT NULL,
    [YTDAcks] INT NULL,
    CONSTRAINT [PK_ReportTBAcks] PRIMARY KEY CLUSTERED ([ID] ASC)
);

