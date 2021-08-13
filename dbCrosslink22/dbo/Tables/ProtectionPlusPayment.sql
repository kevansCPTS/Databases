CREATE TABLE [dbo].[ProtectionPlusPayment] (
    [RowID]         INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [PaymentAmount] MONEY         NOT NULL,
    [PaymentDate]   DATETIME      CONSTRAINT [DF_ProtectionPlusPayment_PaymentDate] DEFAULT (getdate()) NOT NULL,
    [PaymentNote]   VARCHAR (255) NOT NULL,
    [PaymentBy]     VARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_ProtectionPlusPayment] PRIMARY KEY CLUSTERED ([RowID] ASC)
);

