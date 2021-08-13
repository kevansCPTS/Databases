CREATE TABLE [dbo].[EFINBank] (
    [EFINBankID]           CHAR (1)     NOT NULL,
    [BankName]             VARCHAR (25) NOT NULL,
    [DefaultTechFee]       MONEY        NOT NULL,
    [RegistrationIsLive]   BIT          CONSTRAINT [DF_RALBank_RegistrationIsLive] DEFAULT ((0)) NOT NULL,
    [RegistrationHasEnded] BIT          CONSTRAINT [DF_RALBank_RegistrationHasEnded] DEFAULT ((0)) NOT NULL,
    [EROMarkupCap]         MONEY        CONSTRAINT [DF_EFINBank_EROMarkupCap] DEFAULT ((0)) NULL,
    [SBMarkupCap]          MONEY        NULL,
    [RushCardFee]          MONEY        NULL,
    [RefundAdminFee]       MONEY        NULL,
    [FeeCap]               MONEY        NULL,
    [IncludeSBFeeInCap]    BIT          CONSTRAINT [DF_IncludeSBFeeInCap] DEFAULT ((0)) NOT NULL,
    [PrintCheckEnabled]    BIT          CONSTRAINT [DF_EFINBank_PrintCheckEnabled] DEFAULT ((1)) NOT NULL,
    [StateAdminFee]        MONEY        NULL,
    [editedBy]             VARCHAR (30) NOT NULL,
    [editDate]             DATE         DEFAULT (getdate()) NOT NULL,
    [DisplayOrder]         INT          CONSTRAINT [DF_tblTable_fldName] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_RALBank] PRIMARY KEY CLUSTERED ([EFINBankID] ASC)
);

