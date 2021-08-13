CREATE TABLE [dbo].[tblXlinkUsedPasswords] (
    [PasswordID]   INT          IDENTITY (1, 1) NOT NULL,
    [PasswordType] CHAR (1)     NOT NULL,
    [UserID]       INT          NOT NULL,
    [LoginID]      VARCHAR (50) NULL,
    [Password]     VARCHAR (35) NULL,
    [editedBy]     VARCHAR (30) NOT NULL,
    [editDate]     DATE         DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblXlinkUsedPasswords] PRIMARY KEY CLUSTERED ([PasswordID] ASC)
);

