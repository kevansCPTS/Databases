CREATE TABLE [dbo].[tblChecklist] (
    [account_id]  VARCHAR (8)  NOT NULL,
    [chkListItem] VARCHAR (30) NOT NULL,
    [checkedDate] DATETIME     NULL,
    [checkedBy]   VARCHAR (11) NULL,
    CONSTRAINT [PK_tblChecklist] PRIMARY KEY CLUSTERED ([account_id] ASC, [chkListItem] ASC)
);

