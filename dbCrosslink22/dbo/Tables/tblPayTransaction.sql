CREATE TABLE [dbo].[tblPayTransaction] (
    [payId]     INT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [pssn]      INT      NOT NULL,
    [bankId]    CHAR (1) NULL,
    [feeType]   TINYINT  NOT NULL,
    [payAmount] MONEY    NOT NULL,
    [payDate]   DATE     NOT NULL,
    CONSTRAINT [PK_tblPayTransaction] PRIMARY KEY NONCLUSTERED ([payId] ASC)
);


GO
CREATE CLUSTERED INDEX [CDX_tblPayTransaction]
    ON [dbo].[tblPayTransaction]([pssn] ASC, [bankId] ASC, [payDate] ASC);

