CREATE TABLE [dbo].[tblLiveLinkQueue] (
    [liveLinkQueueID]   INT           IDENTITY (1, 1) NOT NULL,
    [description]       VARCHAR (128) NULL,
    [liveLinkQueueName] VARCHAR (128) NULL,
    CONSTRAINT [liveLinkQueueID] PRIMARY KEY CLUSTERED ([liveLinkQueueID] ASC)
);

