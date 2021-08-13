CREATE TABLE [dbo].[WebserviceEfinDiff] (
    [WebserviceEfinDiffId] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Efin]                 INT           NOT NULL,
    [LastFetched]          DATETIME      NOT NULL,
    [ClientId]             VARCHAR (200) NOT NULL,
    [Change_ID]            INT           NULL,
    CONSTRAINT [PK_WebserviceEfinDiff] PRIMARY KEY CLUSTERED ([WebserviceEfinDiffId] ASC)
);

