CREATE TABLE [dbo].[tblXlinkXMLDataForPublish] (
    [RowID]            INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Account]          VARCHAR (8)   NOT NULL,
    [franchiseuser_id] INT           NULL,
    [user_id]          INT           NULL,
    [TableName]        VARCHAR (50)  NOT NULL,
    [XMLTag]           VARCHAR (10)  NOT NULL,
    [XMLData]          VARCHAR (MAX) NOT NULL,
    [Published]        BIT           CONSTRAINT [DF_tblXlinkXMLDataForPublish_Published] DEFAULT ((0)) NOT NULL,
    [CreatedDate]      DATETIME      CONSTRAINT [DF_tblXlinkXMLDataForPublish_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblXlinkXMLDataForPublish] PRIMARY KEY CLUSTERED ([RowID] ASC)
);

