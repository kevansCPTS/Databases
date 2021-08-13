CREATE TABLE [dbo].[WebserviceAccountDiff] (
    [WebserviceAccountDiffId] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Account]                 VARCHAR (200) NOT NULL,
    [LastFetched]             DATETIME      NOT NULL,
    [ClientId]                VARCHAR (200) NOT NULL,
    [Change_ID]               INT           NULL,
    CONSTRAINT [PK_WebserviceAccountDiff] PRIMARY KEY CLUSTERED ([WebserviceAccountDiffId] ASC)
);

