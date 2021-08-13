CREATE TABLE [dbo].[tblEFINValidationHist] (
    [histId]               INT          IDENTITY (1, 1) NOT NULL,
    [ID]                   INT          NOT NULL,
    [IndustryCode]         CHAR (6)     NOT NULL,
    [Sequence]             INT          NOT NULL,
    [TrackingNumber]       CHAR (20)    NULL,
    [Efin]                 INT          NOT NULL,
    [ResultEfinStatus]     CHAR (1)     NULL,
    [EfinOwnerTin]         CHAR (9)     NULL,
    [EfinOwnerTinType]     CHAR (1)     NULL,
    [EfinOwnerLegalName]   VARCHAR (50) NULL,
    [EfinOwnerDBAName]     VARCHAR (50) NULL,
    [EfinAddress1]         VARCHAR (50) NULL,
    [EfinAddress2]         VARCHAR (50) NULL,
    [EfinCity]             VARCHAR (30) NULL,
    [EfinState]            VARCHAR (20) NULL,
    [EfinPostal]           CHAR (10)    NULL,
    [EfinCountry]          CHAR (3)     NULL,
    [EfinContactName]      VARCHAR (30) NULL,
    [EfinContactPhone]     VARCHAR (20) NULL,
    [IndustrySoftwareId]   CHAR (10)    NULL,
    [CustomerVendorID]     CHAR (16)    NULL,
    [IndustryActionFlag]   CHAR (1)     NULL,
    [SentDate]             DATETIME     NULL,
    [CreatedDate]          DATETIME     NOT NULL,
    [CreatedBy]            VARCHAR (20) NULL,
    [ModifiedDate]         DATETIME     NOT NULL,
    [ModifiedBy]           VARCHAR (20) NULL,
    [EFINUpdatedDate]      DATETIME     NULL,
    [ResultEfinStatusDate] DATETIME     NULL,
    [HistCreatedDate]      DATETIME     CONSTRAINT [DF_tblEFINValidationHist_CreatedDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_tblEFINValidationHist] PRIMARY KEY NONCLUSTERED ([histId] ASC)
);


GO
CREATE CLUSTERED INDEX [CDX_tblEFINValidationHist]
    ON [dbo].[tblEFINValidationHist]([ID] ASC, [histId] ASC);

