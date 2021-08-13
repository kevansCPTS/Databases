CREATE TABLE [dbo].[tblAncillaryProductBankApproval] (
    [aprodId]            INT           NOT NULL,
    [bankId]             CHAR (1)      NOT NULL,
    [vendorBankContact]  BIT           CONSTRAINT [DF_tblAncillaryProductBankApproval_vendorBankContact] DEFAULT ((0)) NOT NULL,
    [peiBankFollowUp]    BIT           CONSTRAINT [DF_tblAncillaryProductBankApproval_peiBankFollowUp] DEFAULT ((0)) NOT NULL,
    [vendorBankApproved] BIT           CONSTRAINT [DF_tblAncillaryProductBankApproval_vendorBankApproved] DEFAULT ((0)) NOT NULL,
    [notes]              VARCHAR (MAX) NULL,
    [createDate]         DATETIME2 (7) CONSTRAINT [DF_tblAncillaryProductBankApproval_createDate] DEFAULT (getdate()) NOT NULL,
    [createBy]           VARCHAR (50)  CONSTRAINT [DF_tblAncillaryProductBankApproval_createBy] DEFAULT (suser_sname()) NOT NULL,
    [modifyDate]         DATETIME2 (7) CONSTRAINT [DF_tblAncillaryProductBankApproval_modifyDate] DEFAULT (getdate()) NOT NULL,
    [modifyBy]           VARCHAR (50)  CONSTRAINT [DF_tblAncillaryProductBankApproval_modifyBy] DEFAULT (suser_sname()) NOT NULL,
    [peiBankHasApproval] BIT           NULL,
    CONSTRAINT [PK_tblAncillaryProductBankApproval] PRIMARY KEY CLUSTERED ([aprodId] ASC, [bankId] ASC)
);

