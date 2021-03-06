
/************************************************************************************************
Name: up_RegApp
Purpose: Procedure to replace the following inline SQL that calls nested levels of views:

        select distinct 
            ba.BankAppID BankAppID20_
            , ba.AccountID AccountID20_
            , ba.Address Address20_
            , ba.AlternatePhone Alternat4_20_
            , ba.Bank Bank20_
            , ba.BankID BankID20_
            , ba.CheckName CheckName20_
            , ba.City City20_
            , ba.Company Company20_
            , ba.CompanyId CompanyId20_
            , ba.Deleted Deleted20_
            , ba.Delivered Delivered20_
            , ba.DeliveredDate Deliver13_20_
            , ba.DistributorId Distrib14_20_
            , ba.Efin Efin20_
            , ba.EfinID EfinID20_
            , ba.EfinProduct EfinPro17_20_
            , ba.EfinStatus EfinStatus20_
            , ba.EFINHolderDOB EFINHol19_20_
            , ba.EFINHolderFirstName EFINHol20_20_
            , ba.EFINHolderLastName EFINHol21_20_
            , ba.EFINHolderSSN EFINHol22_20_
            , ba.EIN EIN20_
            , ba.Email Email20_
            , ba.EROBankFee EROBankFee20_
            , ba.EROTranFee EROTranFee20_
            , ba.ErrorCode ErrorCode20_
            , ba.ErrorDescription ErrorDe28_20_
            , ba.Fax Fax20_
            , ba.FeeAccountNumber FeeAcco30_20_
            , ba.FeeAccountType FeeAcco31_20_
            , ba.FeeRoutingNumber FeeRout32_20_
            , ba.HoldFlag HoldFlag20_
            , ba.LocationId LocationId20_
            , ba.Master Master20_
            , ba.PEIRALTransmitterFee PEIRALT37_20_
            , ba.PEITechFee PEITechFee20_
            , ba.Phone Phone20_
            , ba.RacsOnly RacsOnly20_
            , ba.Registered Registered20_
            , ba.RegisteredDescription Registe42_20_
            , ba.Roll Roll20_
            , ba.SBFeeAll SBFeeAll20_
            , ba.SBName SBName20_
            , ba.SBPrepFee SBPrepFee20_
            , ba.Sent Sent20_
            , ba.SentDate SentDate20_
            , ba.State State20_
            , ba.SubmittedRecordType Submitt50_20_
            , ba.UpdatedDate Updated51_20_
            , ba.UserID UserID20_
            , ba.Zip Zip20_ 
        from 
            dbCrosslink12.dbo.vwRegistrationApplication vwregistra0_ 
        where 
            ba.BankID= 'A'
            and ba.Efin= 8193


The updated procedure removes the reference to the nested views and repaces them 
with targeted stored procedures. It also removes the field name aliasing that was
introduced by the framework.


Called By:
Parameters: 
 1 @efin int
 2 @bankId  char(1)

Result Codes:
 0 success

Author: Ken Evans 10/19/2012

Changes/Update:

    KJE - 05/15/2013:
        Added the following fields the @bankApp table to keep this in sync with the changes made to up_bankApp:
			AgreeFeeOption bit
			AgreeFeeOptionDate datetime
			AgreeRushCard bit
			AgreeRushCardDate datetime
			AgreeBank bit
			AgreeDate datetime

	JW - 07/23/2013:
		Removed the MultiOffice field

	KJE - 09/26/2013
		Added SCOStatus to the output per Paulo and Bill. 

**************************************************************************************************/
CREATE procedure [dbo].[up_RegApp]
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
,   AgreeBank bit
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
,	SystemHold bit
)
set nocount on

    -- Get the bank application data
    insert @bankApp
        exec up_bankApp @efin, @bankId



--select * from dbo.vwRegistrationApplication
--select * from @bankApp


    select     
        ba.BankAppID 
    ,   ba.AccountID 
    ,   ba.[Address] 
    ,   ba.AlternatePhone 
    ,   ba.Bank 
    ,   ba.BankID 
    ,   ba.CheckName 
    ,   ba.City 
    ,   ba.Company 
    ,   ba.CompanyId 
    ,   ba.Deleted 
    ,   ba.Delivered 
    ,   ba.DeliveredDate 
    ,   ba.DistributorId 
    ,   ba.Efin 
    ,   ba.EfinID 
    ,   ba.EfinProduct 
    ,   ba.EfinStatus 
    ,   ba.EFINHolderDOB 
    ,   ba.EFINHolderFirstName 
    ,   ba.EFINHolderLastName 
    ,   ba.EFINHolderSSN 
    ,   ba.EIN 
    ,   ba.Email 
    ,   ba.EROBankFee 
    ,   ba.EROTranFee 
    ,   ba.ErrorCode 
    ,   ba.ErrorDescription 
    ,   ba.Fax 
    ,   ba.FeeAccountNumber 
    ,   ba.FeeAccountType 
    ,   ba.FeeRoutingNumber 
    ,   ba.HoldFlag 
    ,   ba.LocationId 
    ,   ba.[Master] 
    ,   ba.PEIRALTransmitterFee 
    ,   ba.PEITechFee 
    ,   ba.Phone 
    ,   ba.RacsOnly 
    ,   ba.Registered 
    ,   ba.RegisteredDescription 
    ,   ba.Roll 
    ,   ba.SBFeeAll 
    ,   ba.SBName 
    ,   ba.SBPrepFee 
    ,   ba.[Sent] 
    ,   ba.SentDate 
    ,   ba.[State] 
    ,   ba.SubmittedRecordType 
    ,   ba.UpdatedDate 
    ,   ba.UserID 
    ,   ba.Zip 
    ,	ba.SystemHold
	,	e.SCOStatus
    from         
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
		join dbo.efin e on ba.EfinID = e.EfinID








