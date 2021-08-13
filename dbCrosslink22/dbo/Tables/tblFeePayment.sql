CREATE TABLE [dbo].[tblFeePayment] (
    [FeePaymentID]   INT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [PSSN]           INT      NOT NULL,
    [RecordDate]     DATETIME CONSTRAINT [DF_tblFeePayment_RecordDate] DEFAULT (getdate()) NOT NULL,
    [FeePaymentDate] DATETIME NOT NULL,
    [FeePayAmount]   INT      NOT NULL,
    [TranPayAmount]  INT      NOT NULL,
    [SBPayAmount]    INT      NOT NULL,
    [TPA]            BIT      CONSTRAINT [DF_tblFeePayment_TPA] DEFAULT ((0)) NOT NULL,
    [Roll]           BIT      CONSTRAINT [DF_tblFeePayment_Roll] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblFeePayment] PRIMARY KEY CLUSTERED ([FeePaymentID] ASC)
);

