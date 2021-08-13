CREATE TABLE [dbo].[tblXeroBridgeSecrets] (
    [Id]        INT            IDENTITY (1, 1) NOT NULL,
    [UserId]    INT            NOT NULL,
    [Secret]    NVARCHAR (255) NOT NULL,
    [Timestamp] DATETIME       NOT NULL,
    CONSTRAINT [PK_tblXeroBridgeSecrets] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);


GO
CREATE CLUSTERED INDEX [CDX_tblXeroBridgeSecrets]
    ON [dbo].[tblXeroBridgeSecrets]([UserId] ASC);

