CREATE TABLE [dbo].[tblTaxPayerRemoteSignature] (
    [SignaturePk]               INT             IDENTITY (1, 1) NOT NULL,
    [DocumentPk]                INT             NULL,
    [SignatureType]             INT             NULL,
    [SignatureImage]            VARBINARY (MAX) NULL,
    [DateOfBirth]               DATETIME        NULL,
    [Last4SSN]                  VARCHAR (4)     NULL,
    [LastName]                  VARCHAR (100)   NULL,
    [DateCaptured]              DATETIME        NULL,
    [DateDelivered]             DATETIME        NULL,
    [BeanstalkId]               INT             NULL,
    [DateExpired]               DATETIME        NULL,
    [FilerEIN]                  VARCHAR (10)    NULL,
    [BankType]                  INT             NULL,
    [IPAddress]                 NVARCHAR (100)  NULL,
    [IPAddress_X_Forwarded_For] VARCHAR (8000)  NULL,
    CONSTRAINT [PK__tblTaxPa__3DC5E08BDFC0E3A0] PRIMARY KEY CLUSTERED ([SignaturePk] ASC)
);

