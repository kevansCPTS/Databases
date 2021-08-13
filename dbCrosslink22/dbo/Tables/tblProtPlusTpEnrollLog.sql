CREATE TABLE [dbo].[tblProtPlusTpEnrollLog] (
    [logId]        INT           IDENTITY (1, 1) NOT NULL,
    [tpId]         INT           NOT NULL,
    [postData]     VARCHAR (MAX) NULL,
    [responseCode] SMALLINT      NULL,
    [responseData] VARCHAR (MAX) NULL,
    [submitDate]   DATETIME      NULL,
    CONSTRAINT [PK_tblProtPlusTpEnrollLog] PRIMARY KEY NONCLUSTERED ([logId] ASC)
);

