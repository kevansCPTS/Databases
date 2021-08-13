CREATE TABLE [dbo].[BillableFeeOptionReturn] (
    [PrimarySSN]     INT          NOT NULL,
    [UserID]         INT          NOT NULL,
    [FilingStatus]   TINYINT      NOT NULL,
    [SBFee]          MONEY        NOT NULL,
    [PEIProtPlusFee] MONEY        NOT NULL,
    [ReturnGUID]     VARCHAR (36) NULL,
    CONSTRAINT [PK_tblBillableFeeOptionReturns] PRIMARY KEY CLUSTERED ([PrimarySSN] ASC, [UserID] ASC, [FilingStatus] ASC)
);

