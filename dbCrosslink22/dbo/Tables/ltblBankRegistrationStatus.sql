CREATE TABLE [dbo].[ltblBankRegistrationStatus] (
    [BankID]       CHAR (1)     NOT NULL,
    [EFINStatus]   CHAR (1)     NOT NULL,
    [Description]  VARCHAR (30) CONSTRAINT [DF_ltblBankRegistrationStatus_Description] DEFAULT ('') NOT NULL,
    [Registered]   CHAR (1)     NOT NULL,
    [LockedAtBank] BIT          CONSTRAINT [DF_ltblBankRegistrationStatus_LockedAtBank] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ltblBankRegistrationStatus] PRIMARY KEY CLUSTERED ([BankID] ASC, [EFINStatus] ASC)
);

