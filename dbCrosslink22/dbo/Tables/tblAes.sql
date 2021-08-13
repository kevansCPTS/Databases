CREATE TABLE [dbo].[tblAes] (
    [aesid]  INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [userid] INT           NOT NULL,
    [siteid] NCHAR (7)     NULL,
    [aes]    VARCHAR (MAX) NULL,
    [tstamp] DATETIME      CONSTRAINT [DF_tblAes_tstamp] DEFAULT (getdate()) NOT NULL,
    [reset]  CHAR (1)      NULL,
    CONSTRAINT [PK_tblAes] PRIMARY KEY CLUSTERED ([aesid] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [user_site_tm]
    ON [dbo].[tblAes]([userid] ASC, [siteid] ASC, [tstamp] DESC);

