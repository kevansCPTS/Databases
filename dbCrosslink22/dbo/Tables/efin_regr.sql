CREATE TABLE [dbo].[efin_regr] (
    [rowID]              INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Efin]               INT           NULL,
    [BankCode]           VARCHAR (1)   NULL,
    [ResponseDate]       DATETIME      NULL,
    [EfinStatus]         VARCHAR (1)   NULL,
    [EfinError]          VARCHAR (50)  NULL,
    [ErrorDescription]   VARCHAR (150) NULL,
    [EfinProduct]        VARCHAR (1)   NULL,
    [RalPrepFee]         INT           NULL,
    [TransmitterPrepFee] INT           NULL,
    [SBPrepFee]          INT           NULL,
    [BankAppID]          INT           NULL,
    [timestamp]          DATETIME      CONSTRAINT [DF_efin_regr_timestamp] DEFAULT (getdate()) NOT NULL,
    [EfinBankFee]        INT           NULL,
    [EfinCompliance]     CHAR (1)      NULL,
    [EfinCard]           CHAR (1)      NULL,
    [EfinPrint]          CHAR (1)      NULL,
    [EfinProduct2]       CHAR (1)      NULL,
    CONSTRAINT [PK_efin_regr] PRIMARY KEY NONCLUSTERED ([rowID] ASC)
);


GO
CREATE CLUSTERED INDEX [CDX_efin_regr]
    ON [dbo].[efin_regr]([Efin] ASC);


GO
CREATE NONCLUSTERED INDEX [ID1_efin_regr]
    ON [dbo].[efin_regr]([BankAppID] ASC, [BankCode] ASC);

