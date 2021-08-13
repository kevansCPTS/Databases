CREATE TABLE [dbo].[tblCADMemberDataHist] (
    [HistId]          INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [pssn]            INT           NULL,
    [Account]         VARCHAR (8)   NULL,
    [EFIN]            INT           NULL,
    [UserId]          INT           NULL,
    [fdate]           DATETIME      NULL,
    [req_cadr_fee]    INT           NULL,
    [cadr_pay_date]   DATE          NULL,
    [cadr_pay_amt]    INT           NULL,
    [StatusId]        TINYINT       NULL,
    [StatusDate]      SMALLDATETIME CONSTRAINT [DF_tblCADMemberDataHist_StatusDate] DEFAULT (getdate()) NULL,
    [CADRResult]      VARCHAR (MAX) NULL,
    [CADMemberId]     VARCHAR (25)  NULL,
    [HistoryActionId] TINYINT       NOT NULL,
    [HistoryDate]     SMALLDATETIME CONSTRAINT [DF_tblCADMemberDataHist_HistoryDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblCADMemberDataHist] PRIMARY KEY NONCLUSTERED ([HistId] ASC)
);


GO
CREATE CLUSTERED INDEX [CDX_[tblCADMemberDataHist]
    ON [dbo].[tblCADMemberDataHist]([Account] ASC, [UserId] ASC, [EFIN] ASC, [pssn] ASC, [HistId] ASC);

