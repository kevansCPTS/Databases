CREATE TABLE [dbo].[tblFeeOptionBalance] (
    [FeeOptionBalanceID]    INT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [EFIN]                  INT      NOT NULL,
    [BankID]                CHAR (1) NOT NULL,
    [Amount]                MONEY    NOT NULL,
    [RecordType]            INT      NOT NULL,
    [RecordDate]            DATETIME CONSTRAINT [DF_tblFeeOptionBalance_RecordDate] DEFAULT (getdate()) NOT NULL,
    [YearToDateAmount]      MONEY    NULL,
    [YearToDateReturnCount] INT      NULL,
    CONSTRAINT [PK_tblFeeOptionBalance] PRIMARY KEY CLUSTERED ([FeeOptionBalanceID] ASC)
);

