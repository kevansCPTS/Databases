CREATE TABLE [dbo].[tblSubmit] (
    [primid]        INT           NOT NULL,
    [returnid]      INT           NULL,
    [dcnx]          CHAR (12)     NULL,
    [stateid]       CHAR (2)      NULL,
    [efin]          INT           NULL,
    [userid]        INT           NULL,
    [userspec]      INT           NULL,
    [pctrl]         CHAR (4)      NULL,
    [sssn]          INT           NULL,
    [sctrl]         CHAR (4)      NULL,
    [archive_no]    INT           NULL,
    [yy]            SMALLINT      NOT NULL,
    [jday]          CHAR (3)      NOT NULL,
    [seqno]         INT           NOT NULL,
    [receiptdt]     DATETIME      NULL,
    [substatus]     CHAR (1)      NULL,
    [timestamp]     CHAR (19)     NULL,
    [linksubid]     CHAR (20)     NULL,
    [stsubmittype]  CHAR (25)     NULL,
    [schemaver]     CHAR (50)     NULL,
    [fedcopy]       CHAR (1)      NULL,
    [formtype1040]  CHAR (1)      NULL,
    [onlinetype]    CHAR (1)      NULL,
    [recTS]         DATETIME2 (0) NULL,
    [mefhold]       CHAR (1)      NULL,
    [taxbegin]      CHAR (8)      NULL,
    [taxend]        CHAR (8)      NULL,
    [schemaloadver] CHAR (20)     NULL,
    [filingtype]    CHAR (1)      NULL,
    [subtype]       CHAR (2)      COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [GovCode]       CHAR (4)      NULL,
    [TxnCode]       CHAR (1)      NULL,
    [fetchSeq]      CHAR (4)      NULL,
    [taxYear]       CHAR (4)      NULL,
    CONSTRAINT [PK_tblSubmit_1] PRIMARY KEY CLUSTERED ([jday] ASC, [seqno] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblSubmitSsn]
    ON [dbo].[tblSubmit]([primid] ASC);

