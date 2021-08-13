CREATE TABLE [dbo].[WebserviceClientAudit] (
    [ClientAuditId] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ClientID]      VARCHAR (200) NOT NULL,
    [Service]       VARCHAR (100) NOT NULL,
    [NumRows]       INT           NOT NULL,
    [Timestamp]     DATETIME      CONSTRAINT [DF_WebserviceClientAudit_Timestamp] DEFAULT (getdate()) NOT NULL,
    [IPAddress]     VARCHAR (50)  NULL,
    [Details]       VARCHAR (200) NULL,
    [MetaData]      VARCHAR (MAX) NULL,
    CONSTRAINT [PK_WebserviceClientAudit] PRIMARY KEY CLUSTERED ([ClientAuditId] ASC),
    CONSTRAINT [FK_WebserviceClientAudit_WebserviceClient] FOREIGN KEY ([ClientID]) REFERENCES [dbo].[WebserviceClient] ([ClientId])
);

