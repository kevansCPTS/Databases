CREATE TABLE [dbo].[ltblXlinkXMLTagMap] (
    [TableName]       VARCHAR (50) NOT NULL,
    [FieldName]       VARCHAR (50) NOT NULL,
    [XMLTag]          VARCHAR (10) NOT NULL,
    [Section]         VARCHAR (3)  NULL,
    [PortalFieldName] VARCHAR (50) NULL,
    CONSTRAINT [PK_ltblXlinkXMLTagMap] PRIMARY KEY CLUSTERED ([TableName] ASC, [FieldName] ASC)
);

