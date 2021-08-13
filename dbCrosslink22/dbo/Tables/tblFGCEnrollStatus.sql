CREATE TABLE [dbo].[tblFGCEnrollStatus] (
    [tpId]       INT           IDENTITY (1, 1) NOT NULL,
    [pssn]       INT           NULL,
    [Account]    VARCHAR (8)   NULL,
    [userId]     INT           NULL,
    [EFIN]       INT           NULL,
    [fdate]      DATETIME      NULL,
    [fundDate]   DATETIME      NULL,
    [StatusId]   TINYINT       NULL,
    [StatusDate] SMALLDATETIME CONSTRAINT [DF_tblFGCEnrollStatus_StatusDate] DEFAULT (getdate()) NULL,
    [logId]      INT           NULL,
    [fgcId]      INT           NULL,
    CONSTRAINT [PK_tblFGCEnrollStatus] PRIMARY KEY NONCLUSTERED ([tpId] ASC),
    CONSTRAINT [UC_tblFGCEnrollStatus_pssn] UNIQUE CLUSTERED ([pssn] ASC)
);

