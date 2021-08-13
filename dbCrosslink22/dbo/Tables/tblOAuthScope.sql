CREATE TABLE [dbo].[tblOAuthScope] (
    [scope_id]     INT          IDENTITY (1, 1) NOT NULL,
    [scope_name]   VARCHAR (50) NOT NULL,
    [scope_parent] INT          NULL,
    [created_dttm] DATETIME     NOT NULL,
    [updated_dttm] DATETIME     NOT NULL,
    CONSTRAINT [PK_tblOAuthScope] PRIMARY KEY CLUSTERED ([scope_id] ASC),
    CONSTRAINT [FK_tblOAuthScope_parent_to_id] FOREIGN KEY ([scope_parent]) REFERENCES [dbo].[tblOAuthScope] ([scope_id])
);

