CREATE TABLE [dbo].[guidrec] (
    [keyType] CHAR (2)      NULL,
    [guid]    CHAR (32)     NOT NULL,
    [lock]    CHAR (1)      NULL,
    [userid]  CHAR (6)      NULL,
    [recTS]   DATETIME2 (0) NULL,
    CONSTRAINT [PK_guidrec] PRIMARY KEY CLUSTERED ([guid] ASC)
);

