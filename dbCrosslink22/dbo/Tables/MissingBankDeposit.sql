CREATE TABLE [dbo].[MissingBankDeposit] (
    [MissingBankDepositID] INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [pssn]                 INT          NOT NULL,
    [efin]                 INT          NOT NULL,
    [roll_fee_pay_amt]     INT          NOT NULL,
    [roll_sb_pay_amt]      INT          NOT NULL,
    [roll_tran_pay_amt]    INT          NOT NULL,
    [ebnk_pay_amt]         INT          NOT NULL,
    [DepositDate]          DATETIME     CONSTRAINT [DF_MissingBankDeposit_DepositDate] DEFAULT (getdate()) NOT NULL,
    [testcolumn]           VARCHAR (10) NULL,
    CONSTRAINT [PK_MissingBankDeposit] PRIMARY KEY CLUSTERED ([MissingBankDepositID] ASC)
);

