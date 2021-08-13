CREATE TABLE [dbo].[MEFResponse] (
    [MEFResponseID]    INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [returnID]         CHAR (9)      NULL,
    [transactionID]    CHAR (12)     NULL,
    [stateID]          CHAR (2)      NULL,
    [guid]             CHAR (32)     NULL,
    [mefcnt]           INT           NULL,
    [state_flag]       CHAR (1)      NULL,
    [SubmissionID]     CHAR (20)     NOT NULL,
    [ExpectedRefund]   INT           NULL,
    [AcceptanceStatus] CHAR (1)      NULL,
    [DebtCode]         CHAR (1)      NULL,
    [DOBCode]          CHAR (1)      NULL,
    [StatusDate]       CHAR (8)      NULL,
    [Postmark]         CHAR (25)     NULL,
    [ErrorCount]       SMALLINT      NULL,
    [ErrorCodes]       VARCHAR (MAX) NULL,
    [filingtype]       CHAR (1)      NULL,
    [subtype]          CHAR (2)      COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [recTS]            DATETIME      CONSTRAINT [DF_MEFResponse_recTS] DEFAULT (getdate()) NULL,
    [alertcount]       SMALLINT      NULL,
    [primid]           INT           NOT NULL,
    CONSTRAINT [PK_MEFResponse] PRIMARY KEY CLUSTERED ([SubmissionID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ID1_MEFResponse]
    ON [dbo].[MEFResponse]([primid] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MEFResponse_returnID]
    ON [dbo].[MEFResponse]([returnID] ASC)
    INCLUDE([SubmissionID]);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MEFResponse_submissionId]
    ON [dbo].[MEFResponse]([SubmissionID] ASC);

