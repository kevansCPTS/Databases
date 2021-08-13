CREATE TABLE [dbo].[tblLookupTypeMap] (
    [TableName]    VARCHAR (50) NOT NULL,
    [ColumnName]   VARCHAR (50) NOT NULL,
    [LookupTypeId] INT          NOT NULL,
    [CreatedDate]  DATETIME     CONSTRAINT [DF_tblLookupTypeMap_CreatedDate] DEFAULT (getdate()) NULL,
    [CreatedBy]    VARCHAR (50) CONSTRAINT [DF_tblLookupTypeMap_CreatedBy] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_tblLookupTypeMap] PRIMARY KEY CLUSTERED ([TableName] ASC, [ColumnName] ASC, [LookupTypeId] ASC)
);

