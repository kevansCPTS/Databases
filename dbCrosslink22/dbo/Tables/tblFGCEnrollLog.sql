CREATE TABLE [dbo].[tblFGCEnrollLog] (
    [logId]        INT           IDENTITY (1, 1) NOT NULL,
    [tpId]         INT           NOT NULL,
    [postData]     VARCHAR (MAX) NULL,
    [responseData] VARCHAR (MAX) NULL,
    [submitDate]   DATETIME      CONSTRAINT [DF_tblFGCEnrollLog_submitDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_tblFGCEnrollLog] PRIMARY KEY NONCLUSTERED ([logId] ASC)
);


GO
CREATE CLUSTERED INDEX [CDX_tblFGCEnrollLog]
    ON [dbo].[tblFGCEnrollLog]([tpId] ASC);

