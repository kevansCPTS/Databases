CREATE TABLE [dbo].[tblBankPost] (
    [recNum]     INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [pssn]       INT           NULL,
    [recordType] CHAR (2)      NULL,
    [xmlRec]     XML           NULL,
    [cobRec]     VARCHAR (MAX) NULL,
    [delivered]  CHAR (1)      NULL,
    [recTs]      DATETIME      CONSTRAINT [DF_tblBankPost_recTs] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_tblBankPost] PRIMARY KEY NONCLUSTERED ([recNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ID1_tblBankPost]
    ON [dbo].[tblBankPost]([delivered] ASC);

