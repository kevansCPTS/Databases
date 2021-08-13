CREATE TABLE [dbo].[tblEFINValidation] (
    [ID]                   INT          IDENTITY (1, 1) NOT NULL,
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
    [CreatedDate]          DATETIME     CONSTRAINT [DF_tblEFINValidation_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]            VARCHAR (20) NULL,
    [ModifiedDate]         DATETIME     CONSTRAINT [DF_tblEFINValidation_ModifiedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]           VARCHAR (20) NULL,
    [EFINUpdatedDate]      DATETIME     NULL,
    [ResultEfinStatusDate] DATETIME     NULL,
    CONSTRAINT [PK_tblEFINValidation] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

CREATE TRIGGER trg_tblEFINValidation_upsert
	ON dbo.tblEFINValidation
	AFTER INSERT,UPDATE
AS 
	BEGIN
		SET NOCOUNT ON;

		insert dbo.tblEFINValidationHist(
			ID
		,   IndustryCode
		,	[Sequence]
		,   TrackingNumber
		,   Efin
		,   ResultEfinStatus
		,   EfinOwnerTin
		,   EfinOwnerTinType
		,   EfinOwnerLegalName
		,   EfinOwnerDBAName
		,   EfinAddress1
		,   EfinAddress2
		,   EfinCity
		,   EfinState
		,   EfinPostal
		,   EfinCountry
		,   EfinContactName
		,   EfinContactPhone
		,   IndustrySoftwareId
		,   CustomerVendorID
		,   IndustryActionFlag
		,   SentDate
		,   CreatedDate
		,   CreatedBy
		,   ModifiedDate
		,   ModifiedBy
		,   EFINUpdatedDate
		,   ResultEfinStatusDate
		,   HistCreatedDate)
				select 
					i.ID
				,   i.IndustryCode
				,	i.[Sequence]
				,   i.TrackingNumber
				,   i.Efin
				,   i.ResultEfinStatus
				,   i.EfinOwnerTin
				,   i.EfinOwnerTinType
				,   i.EfinOwnerLegalName
				,   i.EfinOwnerDBAName
				,   i.EfinAddress1
				,   i.EfinAddress2
				,   i.EfinCity
				,   i.EfinState
				,   i.EfinPostal
				,   i.EfinCountry
				,   i.EfinContactName
				,   i.EfinContactPhone
				,   i.IndustrySoftwareId
				,   i.CustomerVendorID
				,   i.IndustryActionFlag
				,   i.SentDate
				,   i.CreatedDate
				,   i.CreatedBy
				,   i.ModifiedDate
				,   i.ModifiedBy
				,   i.EFINUpdatedDate
				,   i.ResultEfinStatusDate
				,	getdate() HistCreatedDate
				from 
					inserted i
	END

