CREATE TABLE [dbo].[tblProductUpdates] (
    [updateId]       INT           NOT NULL,
    [package]        VARCHAR (25)  NOT NULL,
    [release]        INT           NOT NULL,
    [ticketId]       INT           NULL,
    [ticketDesc]     VARCHAR (255) NULL,
    [testDate]       DATE          NULL,
    [resolutionNote] VARCHAR (255) NULL,
    [mso]            BIT           NULL,
    [createDate]     DATETIME2 (7) NULL,
    [createBy]       VARCHAR (50)  NULL,
    [modifyDate]     DATETIME2 (7) NULL,
    [modifyBy]       VARCHAR (50)  NULL,
    CONSTRAINT [PK_tblProductUpdates] PRIMARY KEY CLUSTERED ([updateId] ASC)
);

