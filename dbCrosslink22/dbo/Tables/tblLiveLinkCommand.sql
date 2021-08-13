CREATE TABLE [dbo].[tblLiveLinkCommand] (
    [commandID]       INT           IDENTITY (1, 1) NOT NULL,
    [liveLinkQueueID] INT           NULL,
    [command]         VARCHAR (128) NULL,
    [bodySQL]         VARCHAR (MAX) NULL,
    [description]     VARCHAR (128) NULL,
    CONSTRAINT [pk_commandID] PRIMARY KEY CLUSTERED ([commandID] ASC),
    CONSTRAINT [fk_liveLinkQueueID] FOREIGN KEY ([liveLinkQueueID]) REFERENCES [dbo].[tblLiveLinkQueue] ([liveLinkQueueID])
);

