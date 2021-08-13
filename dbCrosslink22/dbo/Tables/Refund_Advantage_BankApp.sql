CREATE TABLE [dbo].[Refund_Advantage_BankApp] (
    [Refund_Advantage_BankAppID]    INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [EfinID]                        INT          NOT NULL,
    [UserID]                        INT          CONSTRAINT [DF_Refund_Advantage_BankApp_UserID] DEFAULT ((0)) NOT NULL,
    [Master]                        INT          CONSTRAINT [DF_Refund_Advantage_BankApp_Master] DEFAULT ((0)) NOT NULL,
    [MasterUserID]                  INT          CONSTRAINT [DF_Refund_Advantage_BankApp_MasterUserID] DEFAULT ((0)) NOT NULL,
    [MasterEFINSSN]                 VARCHAR (9)  NULL,
    [EFINOwnerFirstName]            VARCHAR (15) NULL,
    [EFINOwnerLastName]             VARCHAR (20) NULL,
    [EFINOwnerHomePhone]            VARCHAR (10) NULL,
    [EFINOwnerCellPhone]            VARCHAR (10) NULL,
    [EFINOwnerIDNumber]             VARCHAR (20) NULL,
    [EFINOwnerIDType]               VARCHAR (2)  NULL,
    [EFINOwnerIDExpirationDate]     DATETIME     NULL,
    [EFINOwnerIDIssueState]         VARCHAR (2)  NULL,
    [EFINOwnerAddress]              VARCHAR (35) NULL,
    [EFINOwnerCity]                 VARCHAR (22) NULL,
    [EFINOwnerState]                VARCHAR (2)  NULL,
    [EFINOwnerZip]                  VARCHAR (9)  NULL,
    [EFINOwnerSSN]                  VARCHAR (9)  NULL,
    [EFINOwnerDateOfBirth]          DATETIME     NULL,
    [EFINOwnerEmailAddress]         VARCHAR (50) NULL,
    [OfficeName]                    VARCHAR (35) NULL,
    [OfficeType]                    VARCHAR (1)  NULL,
    [OfficeAddressStreet]           VARCHAR (35) NULL,
    [OfficeAddressCity]             VARCHAR (22) NULL,
    [OfficeAddressState]            VARCHAR (2)  NULL,
    [OfficeAddressZip]              VARCHAR (9)  NULL,
    [OfficeWebsite]                 VARCHAR (50) NULL,
    [OfficePhone]                   VARCHAR (10) NULL,
    [OfficeFax]                     VARCHAR (10) NULL,
    [OfficeLocationType]            VARCHAR (1)  NULL,
    [TaxIDType]                     VARCHAR (1)  NULL,
    [TaxID]                         VARCHAR (9)  NULL,
    [ContactName]                   VARCHAR (36) NULL,
    [ContactTitle]                  VARCHAR (25) NULL,
    [ContactPreferredLanguage]      VARCHAR (1)  NULL,
    [ContactEmailAddress]           VARCHAR (50) NULL,
    [ContactPhone]                  VARCHAR (10) NULL,
    [FeeAccountName]                VARCHAR (35) NULL,
    [FeeRoutingNumber]              VARCHAR (9)  NULL,
    [FeeAccountNumber]              VARCHAR (17) NULL,
    [FeeAccountType]                VARCHAR (1)  NULL,
    [BankRelationshipType]          VARCHAR (1)  NULL,
    [MailTo]                        VARCHAR (35) NULL,
    [MailingAddressStreet]          VARCHAR (35) NULL,
    [MailingAddressCity]            VARCHAR (22) NULL,
    [MailingAddressState]           VARCHAR (2)  NULL,
    [MailingAddressZip]             VARCHAR (9)  NULL,
    [ShipTo]                        VARCHAR (35) NULL,
    [ShippingAddressStreet]         VARCHAR (35) NULL,
    [ShippingAddressCity]           VARCHAR (22) NULL,
    [ShippingAddressState]          VARCHAR (2)  NULL,
    [ShippingAddressZip]            VARCHAR (9)  NULL,
    [BusinessOwnerFirstName]        VARCHAR (15) NULL,
    [BusinessOwnerLastName]         VARCHAR (20) NULL,
    [BusinessOwnerAddress]          VARCHAR (35) NULL,
    [BusinessOwnerCity]             VARCHAR (22) NULL,
    [BusinessOwnerState]            VARCHAR (2)  NULL,
    [BusinessOwnerZip]              VARCHAR (9)  NULL,
    [BusinessOwnerCountry]          VARCHAR (2)  NULL,
    [BusinessOwnerHomePhone]        VARCHAR (10) NULL,
    [BusinessOwnerCellPhone]        VARCHAR (10) NULL,
    [BusinessOwnerDateOfBirth]      DATETIME     NULL,
    [BusinessOwnerSSN]              VARCHAR (9)  NULL,
    [BusinessOwnerIDNumber]         VARCHAR (20) NULL,
    [BusinessOwnerIDType]           VARCHAR (2)  NULL,
    [BusinessOwnerIDExpirationDate] DATETIME     NULL,
    [BusinessOwnerIDState]          VARCHAR (2)  NULL,
    [BusinessOwnerPercentOwned]     INT          NULL,
    [ControlPersonFirstName]        VARCHAR (15) NULL,
    [ControlPersonLastName]         VARCHAR (20) NULL,
    [ControlPersonAddress]          VARCHAR (35) NULL,
    [ControlPersonCity]             VARCHAR (22) NULL,
    [ControlPersonState]            VARCHAR (2)  NULL,
    [ControlPersonZip]              VARCHAR (9)  NULL,
    [ControlPersonCountry]          VARCHAR (2)  NULL,
    [ControlPersonHomePhone]        VARCHAR (10) NULL,
    [ControlPersonCellPhone]        VARCHAR (10) NULL,
    [ControlPersonDateOfBirth]      DATETIME     NULL,
    [ControlPersonSSN]              VARCHAR (9)  NULL,
    [ControlPersonIDNumber]         VARCHAR (20) NULL,
    [ControlPersonIDType]           VARCHAR (2)  NULL,
    [ControlPersonIDExpirationDate] DATETIME     NULL,
    [ControlPersonIDState]          VARCHAR (2)  NULL,
    [ControlPersonTitle]            VARCHAR (25) NULL,
    [CorporationType]               VARCHAR (1)  NULL,
    [CheckMailingAddressType]       VARCHAR (1)  NULL,
    [NumberOfPrincipals]            INT          NULL,
    [NumberOfPersonnel]             INT          NULL,
    [RefusedForRenewal]             VARCHAR (1)  NULL,
    [SharedEFIN]                    VARCHAR (1)  NULL,
    [FundingRatio]                  INT          NULL,
    [YearsInBusiness]               INT          NULL,
    [YearsCurrentAddress]           INT          NULL,
    [YearsBankProducts]             INT          NULL,
    [YearsEFiling]                  INT          NULL,
    [PriorYearEFIN]                 VARCHAR (6)  NULL,
    [PriorYearPrepFeePaid]          INT          NULL,
    [PriorYearBankRALs]             INT          NULL,
    [PriorYearBankRACs]             INT          NULL,
    [PriorYearBankVolumeSource]     VARCHAR (1)  NULL,
    [ProjectedBankProducts]         INT          NULL,
    [PriorYearReturns]              INT          NULL,
    [PriorYearReturnsSource]        VARCHAR (1)  NULL,
    [PriorYearBank]                 VARCHAR (1)  NULL,
    [PriorYearTransmitterUsed]      VARCHAR (2)  NULL,
    [NewToTransmitter]              VARCHAR (1)  NULL,
    [SecurityQuestion]              VARCHAR (1)  NULL,
    [SecurityAnswer]                VARCHAR (25) NULL,
    [EPSProgram]                    VARCHAR (1)  NULL,
    [Checks]                        VARCHAR (1)  NULL,
    [Cards]                         VARCHAR (1)  NULL,
    [LoanIndicator]                 VARCHAR (1)  NULL,
    [SBFee]                         INT          NULL,
    [PEITechFee]                    INT          NULL,
    [PEIRALTransmitterFee]          INT          NULL,
    [EROTranFee]                    INT          NULL,
    [Delivered]                     BIT          CONSTRAINT [DF_Refund_Advantage_BankApp_delivered] DEFAULT ((0)) NOT NULL,
    [Sent]                          BIT          CONSTRAINT [DF_Refund_Advantage_BankApp_Sent] DEFAULT ((0)) NOT NULL,
    [DeliveredDate]                 DATETIME     NULL,
    [SentDate]                      DATETIME     NULL,
    [AgreeBank]                     BIT          CONSTRAINT [DF_Refund_Advantage_BankApp_AgreeBank] DEFAULT ((0)) NOT NULL,
    [AgreeDate]                     DATETIME     NULL,
    [UpdatedBy]                     VARCHAR (11) NULL,
    [UpdatedDate]                   DATETIME     CONSTRAINT [DF_Refund_Advantage_BankApp_UpdatedDate] DEFAULT (getdate()) NULL,
    [Deleted]                       BIT          CONSTRAINT [DF_Refund_Advantage_BankApp_Deleted] DEFAULT ((0)) NOT NULL,
    [Roll]                          CHAR (1)     NULL,
    [FeeAgree]                      BIT          CONSTRAINT [DF_Refund_Advantage_BankApp_FeeAgree] DEFAULT ((0)) NOT NULL,
    [FeeAgreeDate]                  DATETIME     NULL,
    [PEIAgree]                      BIT          CONSTRAINT [DF_Refund_Advantage_BankApp_PEIAgree] DEFAULT ((0)) NOT NULL,
    [PEIAgreeDate]                  DATETIME     NULL,
    [EFilingFee]                    INT          NULL,
    [SystemHold]                    BIT          NULL,
    [Hidden]                        BIT          CONSTRAINT [DF_Refund_Advantage_BankApp_Hidden] DEFAULT ((0)) NOT NULL,
    [NetTranFee]                    INT          NULL,
    [PreAckLoans]                   VARCHAR (1)  NULL,
    [BusinessOwnerEmail]            VARCHAR (50) NULL,
    [AgreeBy]                       VARCHAR (50) NULL,
    [CPTSAdminFee]                  INT          NULL,
    [EFFee]                         INT          NULL,
    [NetEFFee]                      INT          NULL,
    [CPTSAdminEFFee]                INT          NULL,
    [IPAddress]                     VARCHAR (46) NULL,
    [DeviceID]                      VARCHAR (40) NULL,
    [SBFeeAll]                      CHAR (1)     NULL,
    [EFFeeAll]                      CHAR (1)     NULL,
    [TechFee]                       INT          NULL,
    [NetTechFee]                    INT          NULL,
    [CPTSAdminTechFee]              INT          NULL,
    [SuperSBid]                     INT          NULL,
    CONSTRAINT [PK_Refund_Advantage] PRIMARY KEY CLUSTERED ([Refund_Advantage_BankAppID] ASC),
    CONSTRAINT [FK_Refund_Advantage_BankApp_efin] FOREIGN KEY ([EfinID]) REFERENCES [dbo].[efin] ([EfinID])
);


GO

-- =============================================
-- Author:           Charles Krebs
-- Create date: 9/13/2010
-- Description:      Set the Agree Date if Agree Bank is set
-- Edit: Garrison: Added 2 new triggers to toggle dates
-- =============================================
CREATE TRIGGER [dbo].[tgrRefund_Advantage_BankApp_AgreeBank] 
   ON [dbo].[Refund_Advantage_BankApp] 
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
        [dbo].[Refund_Advantage_BankApp] ba join inserted i on ba.[Refund_Advantage_BankAppID] = i.[Refund_Advantage_BankAppID]
        join deleted d on ba.[Refund_Advantage_BankAppID] = d.[Refund_Advantage_BankAppID]


