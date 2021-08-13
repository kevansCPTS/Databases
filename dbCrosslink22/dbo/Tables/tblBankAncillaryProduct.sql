CREATE TABLE [dbo].[tblBankAncillaryProduct] (
    [bankId]     CHAR (1)     NOT NULL,
    [aprodId]    INT          NOT NULL,
    [id]         INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [createDate] DATETIME     NOT NULL,
    [createBy]   VARCHAR (50) NOT NULL,
    [modifyDate] DATETIME     NOT NULL,
    [modifyBy]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_tblBankAncillaryProduct] PRIMARY KEY CLUSTERED ([bankId] ASC, [aprodId] ASC),
    CONSTRAINT [FK_tblankAncillaryProduct_bank] FOREIGN KEY ([bankId]) REFERENCES [dbo].[EFINBank] ([EFINBankID]),
    CONSTRAINT [FK_tblBankAncillaryProduct_aprodId] FOREIGN KEY ([aprodId]) REFERENCES [dbo].[tblAncillaryProduct] ([aprodId])
);

