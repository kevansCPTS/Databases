CREATE TABLE [dbo].[tblFeeOptionTransaction] (
    [FeeOptionTransactionId] BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [BankID]                 CHAR (1)      NOT NULL,
    [efin]                   INT           NOT NULL,
    [RecordType]             INT           NOT NULL,
    [amount]                 MONEY         NOT NULL,
    [sent]                   BIT           CONSTRAINT [DF_tblAdventFeeOptionTransaction_sent] DEFAULT ((0)) NOT NULL,
    [sentDate]               DATETIME      NULL,
    [response]               VARCHAR (200) NULL,
    [responseDate]           DATETIME      NULL,
    [collectedAmountTPG]     MONEY         NULL,
    [toCollectAmountTPG]     MONEY         NULL,
    CONSTRAINT [PK_tblAdventFeeOptionTransaction] PRIMARY KEY CLUSTERED ([FeeOptionTransactionId] ASC)
);

