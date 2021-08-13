CREATE TABLE [dbo].[tblProtPlusEROEnrollStatus] (
    [erollId]    INT         IDENTITY (1, 1) NOT NULL,
    [account]    VARCHAR (8) NOT NULL,
    [efin]       INT         NOT NULL,
    [eStatus]    BIT         NULL,
    [statusDate] DATETIME    NULL,
    [createDate] DATETIME    NULL,
    [logId]      INT         NULL,
    CONSTRAINT [PK_tblProtPlusEROEnrollStatus] PRIMARY KEY NONCLUSTERED ([erollId] ASC)
);


GO
CREATE CLUSTERED INDEX [CDX_tblProtPlusEROEnrollStatus]
    ON [dbo].[tblProtPlusEROEnrollStatus]([account] ASC, [efin] ASC, [logId] DESC);

