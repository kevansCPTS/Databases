CREATE TABLE [dbo].[tblCPTSAdminFeeTier] (
    [account]    VARCHAR (8)   NOT NULL,
    [tierSeq]    TINYINT       NOT NULL,
    [minVal]     INT           NULL,
    [maxVal]     INT           NULL,
    [feeAmount]  INT           NULL,
    [active]     BIT           DEFAULT ((1)) NOT NULL,
    [createDate] DATETIME2 (7) DEFAULT (getdate()) NOT NULL,
    [modifyDate] DATETIME2 (7) DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblCPTSAdminFeeTeir] PRIMARY KEY CLUSTERED ([account] ASC, [tierSeq] ASC)
);

