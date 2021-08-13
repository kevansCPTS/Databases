CREATE TABLE [dbo].[SBTPGW_BankApp] (
    [SBTPGW_BankAppID]            INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [EfinID]                      INT          NOT NULL,
    [UserID]                      INT          CONSTRAINT [DF_SBTPGW_BankApp_UserID] DEFAULT ((0)) NOT NULL,
    [Master]                      INT          CONSTRAINT [DF_SBTPGW_BankApp_Master] DEFAULT ((0)) NOT NULL,
    [OfficeIDENT]                 VARCHAR (5)  NULL,
    [ProductConfiguration]        CHAR (1)     NULL,
    [CompanyName]                 VARCHAR (35) NULL,
    [ManagersFirstName]           VARCHAR (20) NULL,
    [ManagersLastName]            VARCHAR (20) NULL,
    [OfficeAddress]               VARCHAR (40) NULL,
    [OfficeCity]                  VARCHAR (22) NULL,
    [OfficeState]                 VARCHAR (2)  NULL,
    [OfficeZipCode]               VARCHAR (9)  NULL,
    [OfficePhoneNumber]           VARCHAR (10) NULL,
    [ShippingAddress]             VARCHAR (40) NULL,
    [ShippingCity]                VARCHAR (22) NULL,
    [ShippingState]               VARCHAR (2)  NULL,
    [ShippingZipCode]             VARCHAR (9)  NULL,
    [ManagersEmailAddress]        VARCHAR (50) NULL,
    [OwnersEIN]                   VARCHAR (9)  NULL,
    [OwnersSSN]                   VARCHAR (9)  NULL,
    [OwnersFirstName]             VARCHAR (20) NULL,
    [OwnersLastName]              VARCHAR (20) NULL,
    [OwnersAddress]               VARCHAR (40) NULL,
    [OwnersCity]                  VARCHAR (22) NULL,
    [OwnersState]                 VARCHAR (2)  NULL,
    [OwnersZipCode]               VARCHAR (9)  NULL,
    [OwnersPhoneNumber]           VARCHAR (10) NULL,
    [OwnersDateOfBirth]           DATETIME     NULL,
    [ClientOfYoursLastYear]       VARCHAR (1)  NULL,
    [LastYearRALBank]             VARCHAR (1)  NULL,
    [PriorYearVolume]             INT          NULL,
    [PriorYearEFIN]               INT          NULL,
    [OfficeFaxNumber]             VARCHAR (10) NULL,
    [MinimumMasterEFinEFFee]      INT          NULL,
    [PriorYearBankProductsFunded] INT          NULL,
    [FeeRoutingNumber]            VARCHAR (9)  NULL,
    [FeeAccountNumber]            VARCHAR (17) NULL,
    [FeeAccountType]              VARCHAR (1)  NULL,
    [Delivered]                   BIT          CONSTRAINT [DF_SBTPGW_BankApp_delivered] DEFAULT ((0)) NOT NULL,
    [Sent]                        BIT          CONSTRAINT [DF_SBTPGW_BankApp_sent] DEFAULT ((0)) NOT NULL,
    [DeliveredDate]               DATETIME     NULL,
    [SentDate]                    DATETIME     NULL,
    [AgreeBank]                   BIT          CONSTRAINT [DF_SBTPGW_BankApp_AgreeBank] DEFAULT ((0)) NOT NULL,
    [AgreeDate]                   DATETIME     NULL,
    [UpdatedBy]                   VARCHAR (11) NULL,
    [UpdatedDate]                 DATETIME     CONSTRAINT [DF_SBTPGW_BankApp_UpdatedDate] DEFAULT (getdate()) NULL,
    [Deleted]                     BIT          CONSTRAINT [DF_SBTPGW_BankApp_Deleted] DEFAULT ((0)) NOT NULL,
    [SubmittedRecordType]         CHAR (1)     NULL,
    [Roll]                        CHAR (1)     NULL,
    [PEITechFee]                  INT          NULL,
    [PEIRALTransmitterFee]        INT          NULL,
    [SBPrepFee]                   INT          NULL,
    [EROTranFee]                  INT          NULL,
    [SecureStorage]               BIT          NULL,
    [SecureDocumentStorage]       BIT          NULL,
    [LockedWhenVacant]            BIT          NULL,
    [SecureLogin]                 BIT          NULL,
    [AntiVirus]                   BIT          NULL,
    [Firewall]                    BIT          NULL,
    [FeeAgree]                    BIT          DEFAULT ((0)) NOT NULL,
    [FeeAgreeDate]                DATETIME     NULL,
    [PEIAgree]                    BIT          DEFAULT ((0)) NOT NULL,
    [PEIAgreeDate]                DATETIME     NULL,
    [DocPrepFee]                  INT          NULL,
    [SystemHold]                  BIT          NULL,
    [OwnersEmailAddress]          VARCHAR (50) NULL,
    [CheckPrint]                  CHAR (1)     CONSTRAINT [DF_SBTPGW_BankApp_CheckPrint] DEFAULT ('D') NULL,
    [SuperSBid]                   INT          NULL,
    [Hidden]                      BIT          CONSTRAINT [DF_SBTPGW_BankApp_Hidden] DEFAULT ((0)) NOT NULL,
    [IPAddress]                   VARCHAR (46) NULL,
    [DeviceID]                    VARCHAR (40) NULL,
    [spanishMaterials]            CHAR (1)     NULL,
    [CheckPrintPref]              CHAR (1)     NULL,
    [NetTranFee]                  INT          NULL,
    [AgreeBy]                     VARCHAR (50) NULL,
    [CPTSAdminFee]                INT          NULL,
    [EFFee]                       INT          NULL,
    [NetEFFee]                    INT          NULL,
    [CPTSAdminEFFee]              INT          NULL,
    [SBFeeAll]                    CHAR (1)     NULL,
    [EFFeeAll]                    CHAR (1)     NULL,
    [HoldShipmentDate]            DATETIME     NULL,
    [TechFee]                     INT          NULL,
    [NetTechFee]                  INT          NULL,
    [CPTSAdminTechFee]            INT          NULL,
    CONSTRAINT [PK_SBTPGW_BankApp] PRIMARY KEY CLUSTERED ([SBTPGW_BankAppID] ASC),
    CONSTRAINT [FK_SBTPGW_BankApp_efin] FOREIGN KEY ([EfinID]) REFERENCES [dbo].[efin] ([EfinID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_SBTPGW_BankApp]
    ON [dbo].[SBTPGW_BankApp]([EfinID] ASC);


GO
-- =============================================
-- Author:           Charles Krebs
-- Create date: 9/13/2010
-- Description:      Set the Agree Date if Agree Bank is set
-- Edit: Garrison: Added 2 new triggers to toggle dates
-- =============================================
CREATE TRIGGER [dbo].[tgrSBTPGW_BankApp_AgreeBank] 
   ON  [dbo].[SBTPGW_BankApp] 
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
        [dbo].[SBTPGW_BankApp] ba join inserted i on ba.[SBTPGW_BankAppID] = i.[SBTPGW_BankAppID]
        join deleted d on ba.[SBTPGW_BankAppID] = d.[SBTPGW_BankAppID]


