CREATE TABLE [dbo].[UserEventType] (
    [UserEventTypeCode] INT          NOT NULL,
    [Description]       VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_UsreEventType] PRIMARY KEY CLUSTERED ([UserEventTypeCode] ASC)
);

