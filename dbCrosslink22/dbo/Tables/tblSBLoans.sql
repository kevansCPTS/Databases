CREATE TABLE [dbo].[tblSBLoans] (
    [Account]    VARCHAR (8) NOT NULL,
    [LoanAmount] MONEY       NOT NULL,
    CONSTRAINT [PK_tblSBLoans] PRIMARY KEY CLUSTERED ([Account] ASC)
);

