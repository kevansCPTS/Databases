CREATE TABLE [dbo].[EFINDocumentType] (
    [DocumentTypeCode] VARCHAR (15) NOT NULL,
    [Description]      VARCHAR (75) NOT NULL,
    [ShortDescription] VARCHAR (30) CONSTRAINT [DF_EFINDocumentType_ShortDescription] DEFAULT ('') NOT NULL,
    [SubType]          VARCHAR (10) NULL,
    CONSTRAINT [PK_EFINDocumentType] PRIMARY KEY CLUSTERED ([DocumentTypeCode] ASC)
);

