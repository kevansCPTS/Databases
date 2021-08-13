/************************************************************************************************
Name: up_RegistrationApplication
Purpose: Procedure to replace the following inline SQL that calls nested levels of views:

        select distinct 
            vwregistra0_.BankAppID as BankAppID20_
            , vwregistra0_.AccountID as AccountID20_
            , vwregistra0_.Address as Address20_
            , vwregistra0_.AlternatePhone as Alternat4_20_
            , vwregistra0_.Bank as Bank20_
            , vwregistra0_.BankID as BankID20_
            , vwregistra0_.CheckName as CheckName20_
            , vwregistra0_.City as City20_
            , vwregistra0_.Company as Company20_
            , vwregistra0_.CompanyId as CompanyId20_
            , vwregistra0_.Deleted as Deleted20_
            , vwregistra0_.Delivered as Delivered20_
            , vwregistra0_.DeliveredDate as Deliver13_20_
            , vwregistra0_.DistributorId as Distrib14_20_
            , vwregistra0_.Efin as Efin20_
            , vwregistra0_.EfinID as EfinID20_
            , vwregistra0_.EfinProduct as EfinPro17_20_
            , vwregistra0_.EfinStatus as EfinStatus20_
            , vwregistra0_.EFINHolderDOB as EFINHol19_20_
            , vwregistra0_.EFINHolderFirstName as EFINHol20_20_
            , vwregistra0_.EFINHolderLastName as EFINHol21_20_
            , vwregistra0_.EFINHolderSSN as EFINHol22_20_
            , vwregistra0_.EIN as EIN20_
            , vwregistra0_.Email as Email20_
            , vwregistra0_.EROBankFee as EROBankFee20_
            , vwregistra0_.EROTranFee as EROTranFee20_
            , vwregistra0_.ErrorCode as ErrorCode20_
            , vwregistra0_.ErrorDescription as ErrorDe28_20_
            , vwregistra0_.Fax as Fax20_
            , vwregistra0_.FeeAccountNumber as FeeAcco30_20_
            , vwregistra0_.FeeAccountType as FeeAcco31_20_
            , vwregistra0_.FeeRoutingNumber as FeeRout32_20_
            , vwregistra0_.HoldFlag as HoldFlag20_
            , vwregistra0_.LocationId as LocationId20_
            , vwregistra0_.Master as Master20_
            , vwregistra0_.PEIRALTransmitterFee as PEIRALT37_20_
            , vwregistra0_.PEITechFee as PEITechFee20_
            , vwregistra0_.Phone as Phone20_
            , vwregistra0_.RacsOnly as RacsOnly20_
            , vwregistra0_.Registered as Registered20_
            , vwregistra0_.RegisteredDescription as Registe42_20_
            , vwregistra0_.Roll as Roll20_
            , vwregistra0_.SBFeeAll as SBFeeAll20_
            , vwregistra0_.SBName as SBName20_
            , vwregistra0_.SBPrepFee as SBPrepFee20_
            , vwregistra0_.Sent as Sent20_
            , vwregistra0_.SentDate as SentDate20_
            , vwregistra0_.State as State20_
            , vwregistra0_.SubmittedRecordType as Submitt50_20_
            , vwregistra0_.UpdatedDate as Updated51_20_
            , vwregistra0_.UserID as UserID20_
            , vwregistra0_.Zip as Zip20_ 
        from 
            dbCrosslink12.dbo.vwRegistrationApplication vwregistra0_ 
        where 
            vwregistra0_.BankID= 'A'
            and vwregistra0_.Efin= 8193


The updated procedure removes the reference to the nested views and repaces them 
with targeted stored procedures.


Called By:
Parameters: 
 1 @efin int
 2 @bankId  char(1)

Result Codes:
 0 success

Author: Ken Evans 06/27/2012
Changes/Update:

    JW - 5/13/2013:
		Added AgreeBank, AgreeDate, AgreeFeeOption, AgreeFeeOptionDate, AgreeRushCard, AgreeRushCardDate columns

	JW - 07/23/2013:
		Removed the MultiOffice field
    

**************************************************************************************************/
CREATE procedure [dbo].[up_RegistrationApplication]
    @efin           int         
,   @bankId         varchar(5)          =   null
as


declare @bankApp table(
    AccountID varchar(8)
,   UserID int 
,   Efin int 
,	AgreeFeeOption bit
,	AgreeFeeOptionDate datetime
,	AgreeRushCard bit
,	AgreeRushCardDate datetime
,   EfinID int
,   Bank varchar(8) 
,   BankID varchar(1) 
,   BankAppID int 
,   Delivered bit 
,   [Sent] bit
,   DeliveredDate datetime
,   SentDate datetime
,   Deleted bit
,   UpdatedDate datetime
,   SubmittedRecordType char(1)
,   [Master] int
,   EIN int
,   EFINHolderSSN varchar(10)
,   EFINHolderFirstName varchar(20)
,   EFINHolderLastName varchar(20)
,   EFINHolderDOB datetime
,   Company varchar(50)
,   [Address] varchar(50)
,   City varchar(50)
,   [State] varchar(2)
,   Zip varchar(10)
,   Phone varchar(25)
,   AlternatePhone varchar(25)
,   Fax varchar(25)
,   Email varchar(75)
,   FeeRoutingNumber varchar(9)
,   FeeAccountNumber varchar(17)
,   FeeAccountType varchar(1)
,   PEITechFee int
,   PEIRALTransmitterFee int
,   EROTranFee int
,   EROBankFee int
,	AgreeBank bit
,	AgreeDate datetime
,   SBPrepFee int
,   Roll char(1)
,   EfinStatus varchar(1)
,   ErrorCode varchar(50)
,   EfinProduct varchar(1)
,   ErrorDescription varchar(350)
,   Registered varchar(1)
,   RegisteredDescription varchar(25)
,   DistributorId int
,   CompanyId int
,   LocationId int
,   CheckName varchar(15)
,   SBFeeAll char(1)
,   HoldFlag char(1)
,   RacsOnly varchar(1)
,   SBName varchar(15)
,   AllowMultipleBanks bit
,   LockedAtBank bit
,   SelectedBank char(1)
,   SelectedBankName varchar(25)
,   BankStatusCode char(1)
,   BankStatusDescription varchar(30)
)

set nocount on

    -- Get the bank application data
    insert @bankApp
        exec up_bankApp @efin, @bankId


SELECT     
    ba.AccountID
,   ba.UserID
,   ba.Efin
,	ba.AgreeFeeOption
,	ba.AgreeFeeOptionDate
,	ba.AgreeRushCard
,	ba.AgreeRushCardDate
,   ba.EfinID
,   ba.Bank
,   ba.BankID
,   ba.BankAppID
,   ba.Delivered
,   ba.[Sent]
,   ba.DeliveredDate
,   ba.SentDate
,   ba.Deleted
,   ba.UpdatedDate
,   ba.SubmittedRecordType
,   ba.[Master]
,   ba.EIN
,   ba.EFINHolderSSN
,   ba.EFINHolderFirstName
,   ba.EFINHolderLastName
,   ba.EFINHolderDOB
,   ba.Company
,   ba.[Address]
,   ba.City
,   ba.[State]
,   ba.Zip
,   ba.Phone
,   ba.AlternatePhone
,   ba.Fax
,   ba.Email
,   ba.FeeRoutingNumber
,   ba.FeeAccountNumber
,   ba.FeeAccountType
,   ba.PEITechFee
,   ba.PEIRALTransmitterFee
,   ba.EROTranFee
,   ba.EROBankFee
,	ba.AgreeBank
,	ba.AgreeDate
,   ba.SBPrepFee
,   ba.Roll
,   ba.EfinStatus
,   ba.ErrorCode
,   ba.EfinProduct
,   ba.ErrorDescription
,   ba.Registered
,   ba.RegisteredDescription
,   ba.DistributorId
,   ba.CompanyId
,   ba.LocationId
,   ba.CheckName
,   ba.SBFeeAll
,   ba.HoldFlag
,   ba.RacsOnly
,   ba.SBName
,   ba.AllowMultipleBanks
,   ba.LockedAtBank
,   ba.SelectedBank
,   ba.SelectedBankName
,   ba.BankStatusCode
,   ba.BankStatusDescription
,   la.BankID Expr1
,   la.Efin Expr2
,   la.BankAppID Expr3
FROM         
    @bankApp ba join (  select
                            ba1.BankID
                        ,   ba1.Efin
                        ,   max(ba1.BankAppID) BankAppID
                        from        
                            @bankApp ba1 join dbo.ltblRegistrationStatusDescription rsd on rsd.Registered = ba1.Registered
                        where    
                            rsd.SendToEFINMaster = 1
                        group by
                            ba1.BankID
                        ,   ba1.Efin) la ON ba.BankAppID = la.BankAppID 
                            AND ba.BankID = la.BankID

--where
--    ba.BankID = 'A'
--    and ba.Efin = 603576



