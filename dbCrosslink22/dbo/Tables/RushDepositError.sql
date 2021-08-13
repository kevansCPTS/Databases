CREATE TABLE [dbo].[RushDepositError] (
    [ID]                   INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [DepositAccountNumber] VARCHAR (50)  NOT NULL,
    [Amount]               VARCHAR (50)  NOT NULL,
    [date]                 DATETIME      CONSTRAINT [DF_RushDepositError_date] DEFAULT (getdate()) NOT NULL,
    [Reason]               VARCHAR (MAX) NULL,
    CONSTRAINT [PK_RushDepositErrors] PRIMARY KEY CLUSTERED ([ID] ASC)
);

