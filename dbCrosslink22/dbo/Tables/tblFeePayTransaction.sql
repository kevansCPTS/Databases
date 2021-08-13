CREATE TABLE [dbo].[tblFeePayTransaction] (
    [transId]    INT      IDENTITY (1, 1) NOT NULL,
    [pssn]       INT      NOT NULL,
    [bankId]     CHAR (1) NOT NULL,
    [aprodId]    INT      NOT NULL,
    [payAmount]  MONEY    NOT NULL,
    [payDate]    DATE     NOT NULL,
    [fileDataId] INT      NOT NULL,
    CONSTRAINT [PK_tblFeePayTransaction] PRIMARY KEY NONCLUSTERED ([transId] ASC)
);


GO
CREATE CLUSTERED INDEX [ID1_tblFeePayTransaction]
    ON [dbo].[tblFeePayTransaction]([pssn] ASC, [aprodId] ASC, [bankId] ASC);

