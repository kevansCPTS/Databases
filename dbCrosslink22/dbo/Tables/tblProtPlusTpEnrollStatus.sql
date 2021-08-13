CREATE TABLE [dbo].[tblProtPlusTpEnrollStatus] (
    [tpId]           INT           IDENTITY (1, 1) NOT NULL,
    [pssn]           INT           NOT NULL,
    [Account]        VARCHAR (8)   NULL,
    [EFIN]           INT           NULL,
    [fdate]          DATETIME      NULL,
    [req_pplus_fee]  INT           NULL,
    [pplus_pay_date] DATE          NULL,
    [pplus_pay_amt]  INT           NULL,
    [StatusId]       TINYINT       NULL,
    [StatusDate]     SMALLDATETIME CONSTRAINT [DF_tblProtPlusTpEnrollStatus_StatusDate] DEFAULT (getdate()) NULL,
    [logId]          INT           NULL,
    CONSTRAINT [PK_tblProtPlusTpEnrollStatus_1] PRIMARY KEY CLUSTERED ([tpId] ASC),
    CONSTRAINT [UC_tblProtPlusTpEnrollStatus_pssn] UNIQUE NONCLUSTERED ([pssn] ASC)
);

