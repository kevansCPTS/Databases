CREATE TABLE [dbo].[FranchiseOwner] (
    [UserID]         INT          NOT NULL,
    [FranchiseName]  VARCHAR (30) NOT NULL,
    [FranchiseSBFee] MONEY        CONSTRAINT [DF_FranchiseOwner_FranchiseSBFee] DEFAULT ((0)) NOT NULL,
    [SBFeeAll]       CHAR (1)     NULL,
    [SBFeeLock]      BIT          CONSTRAINT [DF_SBFeeLock] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_FranchiseOwner] PRIMARY KEY CLUSTERED ([UserID] ASC)
);

