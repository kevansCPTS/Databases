CREATE TABLE [dbo].[RushCardApplication] (
    [RushCardApplicationId]      INT                IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ApplicationId]              INT                NULL,
    [ApplicationDate]            DATETIMEOFFSET (7) NULL,
    [FirstName]                  VARCHAR (32)       NULL,
    [MiddleName]                 VARCHAR (32)       NULL,
    [LastName]                   VARCHAR (32)       NULL,
    [SSN]                        VARCHAR (9)        NOT NULL,
    [HomeTelephone]              VARCHAR (50)       NULL,
    [CellTelephone]              VARCHAR (50)       NULL,
    [Email]                      VARCHAR (64)       NULL,
    [Address1]                   VARCHAR (64)       NULL,
    [Address2]                   VARCHAR (64)       NULL,
    [City]                       VARCHAR (32)       NULL,
    [State]                      VARCHAR (2)        NULL,
    [Zip]                        VARCHAR (10)       NULL,
    [DateOfBirth]                DATETIME           NULL,
    [Sex]                        VARCHAR (1)        NULL,
    [PlasticType]                VARCHAR (25)       NULL,
    [PreferredLanguage]          VARCHAR (25)       NULL,
    [FeePlan]                    VARCHAR (25)       NULL,
    [TermsAndConditionsAccepted] BIT                CONSTRAINT [DF_RushCardApplication_TermsAndConditionsAccepted] DEFAULT ((0)) NULL,
    [StatusID]                   INT                NOT NULL,
    [Status]                     VARCHAR (25)       NULL,
    [HeardAbout]                 VARCHAR (50)       NULL,
    [PromoCode]                  VARCHAR (25)       NULL,
    [ReferAFriendCode]           VARCHAR (25)       NULL,
    [SourceIP]                   VARCHAR (25)       NULL,
    [CardNumber]                 VARCHAR (16)       NULL,
    [CardVerificationCode]       INT                NULL,
    [SubmitterName]              VARCHAR (50)       NULL,
    [PartnerReferrer]            VARCHAR (50)       NULL,
    [StatusUrl]                  VARCHAR (MAX)      NULL,
    [RTN]                        VARCHAR (9)        NULL,
    [DAN]                        VARCHAR (25)       NULL,
    [ValidationTypes]            VARCHAR (MAX)      NULL,
    [GUID]                       VARCHAR (50)       NOT NULL,
    [NotificationType]           INT                NULL,
    [NotificationSource]         VARCHAR (50)       NULL,
    [ReturnId]                   INT                NULL,
    [ApplicationSubmitUrl]       VARCHAR (MAX)      NULL,
    [ApplicationUpdateUrl]       VARCHAR (MAX)      NULL,
    [PersonalizedCard]           BIT                NULL,
    [OptOutOfSMS]                BIT                NULL,
    [RushStatus]                 VARCHAR (50)       NULL,
    [ExternalLocationId]         VARCHAR (50)       NULL,
    [IDVerified]                 BIT                NULL,
    [IdentityQuestionSubmitUrl]  VARCHAR (MAX)      NULL,
    [Errors]                     VARCHAR (MAX)      NULL,
    [RushStatusDescription]      VARCHAR (250)      NULL,
    [Efin]                       INT                NULL,
    CONSTRAINT [PK_RushCardApplication] PRIMARY KEY CLUSTERED ([RushCardApplicationId] ASC)
);


GO
-- =============================================
-- Author:		Robert Petz
-- Create date: 1/17/2012
-- Description:	TEMPORARY - Hotfix to resolve RushCard URL relative pathing issue
-- =============================================
CREATE TRIGGER [dbo].[TEMP_RushCardURLFix] 
   ON  [dbo].[RushCardApplication] 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	
	update r set r.applicationsubmiturl = null, r.applicationupdateurl = null from inserted i inner join rushcardapplication r on r.rushcardapplicationid = i.rushcardapplicationid where i.applicationsubmiturl like '/Application/v2/submit%'
END


