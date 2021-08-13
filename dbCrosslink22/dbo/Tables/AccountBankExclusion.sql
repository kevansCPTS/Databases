CREATE TABLE [dbo].[AccountBankExclusion] (
    [Account] VARCHAR (8) NOT NULL,
    [BankID]  CHAR (1)    NOT NULL,
    CONSTRAINT [PK_AccountBankExclusion] PRIMARY KEY CLUSTERED ([Account] ASC)
);

