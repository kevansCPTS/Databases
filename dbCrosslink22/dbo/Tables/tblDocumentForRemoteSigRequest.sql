CREATE TABLE [dbo].[tblDocumentForRemoteSigRequest] (
    [DocumentPk]       INT             IDENTITY (1, 1) NOT NULL,
    [UniqueId]         VARCHAR (50)    NULL,
    [DocumentData]     VARBINARY (MAX) NULL,
    [DocumentMIMEType] VARCHAR (255)   NULL,
    [DocumentFileName] VARCHAR (255)   NULL,
    [DateCreated]      DATETIME        NULL,
    [TaxReturnGUID]    VARCHAR (50)    NULL,
    [UserId]           INT             NULL,
    [FormType]         VARCHAR (4)     NULL,
    [Is1040]           BIT             CONSTRAINT [DF_tblDocumentForRemoteSigRequest_Is1040] DEFAULT ((1)) NOT NULL,
    [xmldata]          XML             NULL,
    [PSSN]             AS              ([dbo].[udf_get_tblDocumentForRemoteSigRequest_PSSN]([xmldata])) PERSISTED,
    [ZIPC]             AS              ([dbo].[udf_get_tblDocumentForRemoteSigRequest_ZIPC]([xmldata])),
    [MobileReturnId]   BIGINT          NULL,
    CONSTRAINT [PK__tblDocum__1ABE267121CBA58A] PRIMARY KEY CLUSTERED ([DocumentPk] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Guid_Index]
    ON [dbo].[tblDocumentForRemoteSigRequest]([UniqueId] ASC);


GO
CREATE NONCLUSTERED INDEX [ID1_tblDocumentForRemoteSigRequest]
    ON [dbo].[tblDocumentForRemoteSigRequest]([PSSN] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MobileReturnId_tblDocumentForRemoteSigRequest]
    ON [dbo].[tblDocumentForRemoteSigRequest]([MobileReturnId] ASC);

