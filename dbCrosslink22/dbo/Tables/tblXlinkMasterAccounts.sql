CREATE TABLE [dbo].[tblXlinkMasterAccounts] (
    [account_id] VARCHAR (8) NOT NULL,
    [EFIN]       CHAR (6)    CONSTRAINT [DF_tblXlinkMasterAccounts_EFIN] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_tblXlinkMasterAccounts] PRIMARY KEY CLUSTERED ([account_id] ASC)
);

