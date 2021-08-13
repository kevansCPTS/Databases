CREATE TABLE [dbo].[EFINDocument] (
    [EFINDocumentID]   INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Owner]            VARCHAR (10)    NOT NULL,
    [DocumentTypeCode] VARCHAR (15)    NOT NULL,
    [SubTypeValue]     VARCHAR (9)     NULL,
    [DocumentImage]    VARBINARY (MAX) NULL,
    [FileType]         VARCHAR (3)     NOT NULL,
    [SubmittedDate]    DATETIME        NULL,
    [UploadError]      VARCHAR (150)   NULL,
    CONSTRAINT [PK_EFINDocument] PRIMARY KEY CLUSTERED ([EFINDocumentID] ASC),
    CONSTRAINT [FK_EFINDocument_EFINDocumentType] FOREIGN KEY ([DocumentTypeCode]) REFERENCES [dbo].[EFINDocumentType] ([DocumentTypeCode])
);

