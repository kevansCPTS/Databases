CREATE TABLE [dbo].[tblProtPlusEROEnrollLog] (
    [logId]        INT           IDENTITY (1, 1) NOT NULL,
    [account]      VARCHAR (8)   NOT NULL,
    [efin]         INT           NOT NULL,
    [postData]     VARCHAR (MAX) NULL,
    [responseCode] SMALLINT      NULL,
    [responseData] VARCHAR (MAX) NULL,
    [submitDate]   DATETIME      NULL,
    CONSTRAINT [PK_tblProtPlusEROEnrollLog] PRIMARY KEY NONCLUSTERED ([logId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [CDX_tblProtPlusEROEnrollLog]
    ON [dbo].[tblProtPlusEROEnrollLog]([account] ASC, [efin] ASC);

