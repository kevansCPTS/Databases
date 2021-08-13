CREATE TABLE [dbo].[tblFeeTier] (
    [feeType]    INT           NOT NULL,
    [account]    VARCHAR (8)   NOT NULL,
    [tierSeq]    TINYINT       NOT NULL,
    [minVal]     INT           NULL,
    [maxVal]     INT           NULL,
    [feeAmount]  INT           NULL,
    [active]     BIT           CONSTRAINT [DF_tblFeeTier_active] DEFAULT ((1)) NOT NULL,
    [createDate] DATETIME2 (7) CONSTRAINT [DF_tblFeeTier_createDate] DEFAULT (getdate()) NOT NULL,
    [modifyDate] DATETIME2 (7) CONSTRAINT [DF_tblFeeTier_modifyDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblFeeTeir] PRIMARY KEY CLUSTERED ([feeType] ASC, [account] ASC, [tierSeq] ASC)
);

