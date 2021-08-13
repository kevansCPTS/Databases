CREATE TABLE [dbo].[Refundo_BankApp] (
    [Refundo_BankAppID]            INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [EfinID]                       INT          NOT NULL,
    [UserID]                       INT          CONSTRAINT [DF_Refundo_BankApp_UserID] DEFAULT ((0)) NOT NULL,
    [Master]                       INT          CONSTRAINT [DF_Refundo_BankApp_Master] DEFAULT ((0)) NOT NULL,
    [OfficeName]                   VARCHAR (35) NULL,
    [OfficePhysicalStreet]         VARCHAR (35) NULL,
    [OfficePhysicalCity]           VARCHAR (22) NULL,
    [OfficePhysicalState]          VARCHAR (2)  NULL,
    [OfficePhysicalZip]            VARCHAR (9)  NULL,
    [OfficeContactFirstName]       VARCHAR (15) NULL,
    [OfficeContactLastName]        VARCHAR (20) NULL,
    [AlternateOffice1FirstName]    VARCHAR (15) NULL,
    [AlternateOffice1LastName]     VARCHAR (20) NULL,
    [AlternateOfficeContact1Email] VARCHAR (75) NULL,
    [OfficePhoneNumber]            VARCHAR (10) NULL,
    [CellPhoneNumber]              VARCHAR (10) NULL,
    [FaxNumber]                    VARCHAR (10) NULL,
    [EmailAddress]                 VARCHAR (75) NULL,
    [OwnerFirstName]               VARCHAR (15) NULL,
    [OwnerLastName]                VARCHAR (20) NULL,
    [OwnerSSN]                     VARCHAR (9)  NULL,
    [OwnerDOB]                     DATETIME     NULL,
    [EfinOwnerFirstName]           VARCHAR (15) NULL,
    [EfinOwnerLastName]            VARCHAR (20) NULL,
    [OwnerHomePhone]               VARCHAR (10) NULL,
    [OwnerAddress]                 VARCHAR (35) NULL,
    [OwnerCity]                    VARCHAR (22) NULL,
    [OwnerState]                   VARCHAR (2)  NULL,
    [OwnerZip]                     VARCHAR (9)  NULL,
    [IRSTransmittingOfficeInd]     CHAR (1)     NULL,
    [ComplianceWithLawInd]         CHAR (1)     NULL,
    [YearsInBusiness]              INT          NULL,
    [LastYearBankProducts]         INT          NULL,
    [BankProductFacilitator]       VARCHAR (10) NULL,
    [CardProgram]                  CHAR (1)     NULL,
    [MultiOffice]                  CHAR (1)     NULL,
    [TaxPrepLicensing]             CHAR (1)     NULL,
    [ActualNumberBankProducts]     INT          NULL,
    [DocumentStorageInd]           CHAR (1)     NULL,
    [CheckCardStorageInd]          CHAR (1)     NULL,
    [EfinOwnerSSN]                 VARCHAR (9)  NULL,
    [TransmitterFeeDefault]        INT          NULL,
    [OfficeDoorInd]                CHAR (1)     NULL,
    [DocumentAccessInd]            CHAR (1)     NULL,
    [SensitiveDocumentDestInd]     CHAR (1)     NULL,
    [LoginPassInd]                 CHAR (1)     NULL,
    [AntiVirusInd]                 CHAR (1)     NULL,
    [FirewallInd]                  CHAR (1)     NULL,
    [ProductTrainingInd]           CHAR (1)     NULL,
    [PreviousViolationFineInd]     CHAR (1)     NULL,
    [NumOfPersonnel]               INT          NULL,
    [LegalEntityStatusInd]         CHAR (1)     NULL,
    [LLCMembershipRegistration]    CHAR (1)     NULL,
    [FulfillmentShippingStreet]    VARCHAR (35) NULL,
    [FulfillmentShippingCity]      VARCHAR (22) NULL,
    [FulfillmentShippingState]     VARCHAR (2)  NULL,
    [FulfillmentShippingZip]       VARCHAR (9)  NULL,
    [OfficeManagerFirstName]       VARCHAR (15) NULL,
    [OfficeManagerLastName]        VARCHAR (20) NULL,
    [OfficeManagerSSN]             VARCHAR (9)  NULL,
    [OfficeManagerDOB]             DATETIME     NULL,
    [MailingAddress]               VARCHAR (35) NULL,
    [MailingCity]                  VARCHAR (22) NULL,
    [MailingState]                 VARCHAR (2)  NULL,
    [MailingZip]                   VARCHAR (9)  NULL,
    [OfficeContactSSN]             VARCHAR (4)  NULL,
    [AlternateOfficeContact1SSN]   VARCHAR (4)  NULL,
    [EFINOwnerDOB]                 DATETIME     NULL,
    [PTINInd]                      CHAR (1)     NULL,
    [AdvertisingInd]               CHAR (1)     NULL,
    [WebsiteAddress]               VARCHAR (60) NULL,
    [FeeRoutingNumber]             VARCHAR (9)  NULL,
    [FeeAccountNumber]             VARCHAR (17) NULL,
    [FeeAccountType]               VARCHAR (1)  NULL,
    [Delivered]                    BIT          CONSTRAINT [DF_Refundo_BankApp_delivered] DEFAULT ((0)) NOT NULL,
    [Sent]                         BIT          CONSTRAINT [DF_Refundo_BankApp_sent] DEFAULT ((0)) NOT NULL,
    [AgreeBank]                    BIT          CONSTRAINT [DF_Refundo_BankApp_AgreeBank] DEFAULT ((0)) NOT NULL,
    [AgreeDate]                    DATETIME     NULL,
    [DeliveredDate]                DATETIME     NULL,
    [SentDate]                     DATETIME     NULL,
    [UpdatedBy]                    VARCHAR (11) NULL,
    [UpdatedDate]                  DATETIME     CONSTRAINT [DF_Refundo_BankApp_UpdatedDate] DEFAULT (getdate()) NULL,
    [Deleted]                      BIT          CONSTRAINT [DF_Refundo_BankApp_Deleted] DEFAULT ((0)) NOT NULL,
    [SubmittedRecordType]          CHAR (1)     NULL,
    [Roll]                         CHAR (1)     NULL,
    [PEITechFee]                   INT          NULL,
    [PEIRALTransmitterFee]         INT          NULL,
    [EROTranFee]                   INT          NULL,
    [SBPrepFee]                    INT          NULL,
    [FeeAgree]                     BIT          DEFAULT ((0)) NOT NULL,
    [FeeAgreeDate]                 DATETIME     NULL,
    [PEIAgree]                     BIT          CONSTRAINT [DF_Refundo_BankApp_PEIAgree] DEFAULT ((0)) NOT NULL,
    [PEIAgreeDate]                 DATETIME     NULL,
    [CheckStockID]                 CHAR (1)     NULL,
    [DebitProgramInd]              CHAR (1)     NULL,
    [EIN]                          INT          NULL,
    [SystemHold]                   BIT          NULL,
    [Hidden]                       BIT          CONSTRAINT [DF_Refundo_BankApp_Hidden] DEFAULT ((0)) NOT NULL,
    [ReferralCode]                 INT          NULL,
    [ProductAuditPros]             BIT          CONSTRAINT [DF_Refundo_BankApp_ProductAuditPros] DEFAULT ((0)) NOT NULL,
    [ProductBP]                    BIT          CONSTRAINT [DF_Refundo_BankApp_ProductBP] DEFAULT ((0)) NOT NULL,
    [ProductPlasticPay]            BIT          NULL,
    [LastYearFundingRate]          INT          NULL,
    [LastYearFedEfiles]            INT          NULL,
    [NetTranFee]                   INT          NULL,
    [DocPrepFee]                   INT          NULL,
    [IRSEFINValidInd]              CHAR (1)     NULL,
    [AgreeBy]                      VARCHAR (50) NULL,
    [CPTSAdminFee]                 INT          NULL,
    [EFFee]                        INT          NULL,
    [NetEFFee]                     INT          NULL,
    [CPTSAdminEFFee]               INT          NULL,
    [SBFeeAll]                     CHAR (1)     NULL,
    [EFFeeAll]                     CHAR (1)     NULL,
    [IPAddress]                    VARCHAR (46) NULL,
    [OwnerEmail]                   VARCHAR (75) NULL,
    [TechFee]                      INT          NULL,
    [NetTechFee]                   INT          NULL,
    [CPTSAdminTechFee]             INT          NULL,
    [SuperSBid]                    INT          NULL,
    CONSTRAINT [PK_Refundo_BankApp] PRIMARY KEY CLUSTERED ([Refundo_BankAppID] ASC),
    CONSTRAINT [FK_Refundo_BankApp_efin] FOREIGN KEY ([EfinID]) REFERENCES [dbo].[efin] ([EfinID])
);


GO

-- =============================================
-- Author:           Jay Willis
-- Create date: 9/29/2015
-- Description:      Set the Agree Date if Agree Bank is set
-- =============================================
CREATE TRIGGER [dbo].tgrRefundo_BankApp_AgreeBank 
   ON [dbo].[Refundo_BankApp] 
   AFTER INSERT,UPDATE
AS 

set nocount on

    update ba
        set ba.AgreeDate =  case
                                when i.AgreeBank != d.AgreeBank then
                                    case i.AgreeBank
                                        when 1 then getdate()
                                        else null
                                    end
                                else ba.AgreeDate 
                            end
    ,   ba.PEIAgreeDate =   case
                                when i.PEIAgree != d.PEIAgree then
                                    case i.PEIAgree
                                        when 1 then getdate()
                                        else null
                                    end
                                else ba.PEIAgreeDate 
                            end            
    ,   ba.FeeAgreeDate =   case
                                when i.FeeAgree != d.FeeAgree then
                                    case i.FeeAgree
                                        when 1 then getdate()
                                        else null
                                    end
                                else ba.FeeAgreeDate 
                            end 
    from
        [dbo].[Refundo_BankApp] ba join inserted i on ba.[Refundo_BankAppID] = i.[Refundo_BankAppID]
        join deleted d on ba.[Refundo_BankAppID] = d.[Refundo_BankAppID]


