CREATE TABLE [dbo].[tblLookupType] (
    [LookupTypeID]          INT          NOT NULL,
    [LookupTypeDescription] VARCHAR (20) NOT NULL,
    [CreatedBy]             VARCHAR (50) CONSTRAINT [DF_tblLookupType_CreatedBy] DEFAULT (suser_name()) NOT NULL,
    [CreatedDate]           DATETIME     CONSTRAINT [DF_tblLookupType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tblLookupItemType] PRIMARY KEY CLUSTERED ([LookupTypeID] ASC)
);

