CREATE TABLE [dbo].[BulletinType] (
    [BulletinTypeID] INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Description]    VARCHAR (25) NOT NULL,
    CONSTRAINT [PK_BulletinType] PRIMARY KEY CLUSTERED ([BulletinTypeID] ASC),
    CONSTRAINT [FK_BulletinType_BulletinType] FOREIGN KEY ([BulletinTypeID]) REFERENCES [dbo].[BulletinType] ([BulletinTypeID])
);

