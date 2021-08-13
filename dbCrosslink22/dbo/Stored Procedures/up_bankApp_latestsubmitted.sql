

/************************************************************************************************
Name: up_bankApp_latestSubmitted

Called By:

Parameters: 
 1 @bankId  char(1)
 2 @efin int

Result Codes:
 0 success

Author: Ken Evans 12/04/2013

Changes/Update:
    KJE 12/09/2013
        Added the ability to pull ALL apps for a given bank. The efin is now optional.

**************************************************************************************************/
CREATE procedure [dbo].[up_bankApp_latestsubmitted] --'V', 769277
    @bankId         char(1)
,   @efin           int = null
as


declare @bapps table (
    EfinID int
,   Bank varchar(50)
,   BankID varchar(1)
,   BankAppID int
,   Delivered bit 
,   [Sent] bit
,   DeliveredDate datetime 
,   SentDate datetime
,   Deleted bit
,   UpdatedDate datetime
,   SubmittedRecordType char(1) 
,   appMaster int
,   EIN int
,   EFINHolderSSN varchar(9) 
,   EFINHolderFirstName varchar(20)
,   EFINHolderLastName varchar(20)
,   EFINHolderDOB datetime
,   Company varchar(50) 
,   [Address] varchar(50)
,   City varchar(50) 
,   [State] varchar(2)
,   Zip varchar(10)
,   Phone varchar(25) 
,   AlternatePhone varchar(10) 
,   Fax varchar(10)
,   Email varchar(75) 
,   FeeRoutingNumber varchar(9) 
,   FeeAccountNumber varchar(17)
,   FeeAccountType varchar(1)
,   PEITechFee int 
,   PEIRALTransmitterFee int 
,   EROTranFee int
,   SBPrepFee int
,   Roll char(1)
,   DistributorId int 
,   CompanyId int
,   LocationId int 
,   AgreeBank bit
,	AgreeDate datetime
,	DocPrepFee int
,	EFilingFee int
,	SystemHold bit
)

declare @efinRegrMap table(
    BankCode            char(1)
,   BankAppId           int
,   EfinError           varchar(50)
,   EFINProduct         varchar(1)
,   EfinStatus          varchar(1)
,   ErrorDescription    varchar(150)
) 

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
,   appMaster int
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
,   efinMaster int
,   isServiceBureau bit
,   RefundAdvantageCardProgram char(1)
,	DocPrepFee int
,	EFilingFee int
,	SystemHold bit
)

declare @efinId int

set nocount on

    -- Get the efinId for the provided efin
    if (@efin is not null)
        select
            @efinId = e.EfinID
        from
            dbo.efin e
        where
            e.Efin = @efin

    -- Get the Refundo apps
    if isnull(@bankId,'F') = 'F'
        insert @bapps
            select     
                fba.EfinID
            ,   'Refundo' Bank
            ,   'F' BankID
            ,   fba.Refundo_BankAppID BankAppID
            ,   fba.Delivered
            ,   fba.[Sent]
            ,   fba.DeliveredDate
            ,   fba.SentDate
            ,   fba.Deleted
            ,   fba.UpdatedDate
            ,   null SubmittedRecordType
            ,   fba.[Master] appMaster
            ,   0 EIN
            ,   '' EFINHolderSSN
            ,   '' EFINHolderFirstName
            ,   '' EFINHolderLastName
            ,   GETDATE() EFINHolderDOB
            ,   fba.OfficeName Company
            ,   fba.OfficePhysicalStreet "Address"
            ,   fba.OfficePhysicalCity City
            ,   fba.OfficePhysicalState "State"
            ,   fba.OfficePhysicalZip Zip
            ,   fba.OfficePhoneNumber Phone
            ,   '' AlternatePhone
            ,   fba.FaxNumber Fax
            ,   '' Email
            ,   fba.FeeRoutingNumber
            ,   fba.FeeAccountNumber
            ,   fba.FeeAccountType
            ,   fba.PEITechFee
            ,   fba.PEIRALTransmitterFee
            ,   fba.EROTranFee
            ,   fba.SBPrepFee
            ,   fba.Roll
            ,   null DistributorId
            ,   null CompanyId
            ,   null LocationId
            ,	fba.AgreeBank
            ,	fba.AgreeDate
            ,	null DocPrepFee 
            ,	null EFilingFee 
            ,	fba.SystemHold
            from          
                dbo.Refundo_BankApp fba join efin e on fba.EfinID = e.efinId and fba.UserID = e.userId
            where
                fba.EfinID = isnull(@efinId,fba.EfinID)

    -- Get the Republic apps
    if isnull(@bankId,'R') = 'R'
        insert @bapps
            select     
                rba.EfinID
            ,   'Republic' Bank
            ,   'R' BankID
            ,   rba.Republic_BankAppID BankAppID
            ,   rba.Delivered
            ,   rba.[Sent]
            ,   rba.DeliveredDate
            ,   rba.SentDate
            ,   rba.Deleted
            ,   rba.UpdatedDate
            ,   null SubmittedRecordType
            ,   rba.[Master] appMaster
            ,   0 EIN
            ,   '' EFINHolderSSN
            ,   '' EFINHolderFirstName
            ,   '' EFINHolderLastName
            ,   GETDATE() EFINHolderDOB
            ,   rba.OfficeName Company
            ,   rba.OfficePhysicalStreet "Address"
            ,   rba.OfficePhysicalCity City
            ,   rba.OfficePhysicalState "State"
            ,   rba.OfficePhysicalZip Zip
            ,   rba.OfficePhoneNumber Phone
            ,   '' AlternatePhone
            ,   rba.FaxNumber Fax
            ,   '' Email
            ,   rba.FeeRoutingNumber
            ,   rba.FeeAccountNumber
            ,   rba.FeeAccountType
            ,   rba.PEITechFee
            ,   rba.PEIRALTransmitterFee
            ,   rba.EROTranFee
            ,   rba.SBPrepFee
            ,   rba.Roll
            ,   null DistributorId
            ,   null CompanyId
            ,   null LocationId
            ,	rba.AgreeBank
            ,	rba.AgreeDate
            ,	null DocPrepFee 
            ,	null EFilingFee 
            ,	rba.SystemHold
            from          
                dbo.Republic_BankApp rba join efin e on rba.EfinID = e.efinId and rba.UserID = e.userId
            where
                rba.EfinID = isnull(@efinId,rba.EfinID)

    -- Get the Refund Advantage apps
    if isnull(@bankId,'V') = 'V'
        insert @bapps
            select     
                vba.EfinID
            ,   'Ref Adv' Bank
            ,   'V' BankID
            ,   vba.Refund_Advantage_BankAppID BankAppID
            ,   vba.Delivered
            ,   vba.[Sent]
            ,   vba.DeliveredDate
            ,   vba.SentDate
            ,   vba.Deleted
            ,   vba.UpdatedDate
            ,   null SubmittedRecordType
            ,   vba.[Master] appMaster
            ,   0 EIN
            ,   '' EFINHolderSSN
            ,   '' EFINHolderFirstName
            ,   '' EFINHolderLastName
            ,   GETDATE() EFINHolderDOB
            ,   vba.OfficeName Company
            ,   vba.OfficeAddressStreet "Address"
            ,   vba.OfficeAddressCity City
            ,   vba.OfficeAddressState "State"
            ,   vba.OfficeAddressZip Zip
            ,   vba.OfficePhone Phone
            ,   '' AlternatePhone
            ,   vba.OfficeFax Fax
            ,   '' Email
            ,   vba.FeeRoutingNumber
            ,   vba.FeeAccountNumber
            ,   vba.FeeAccountType
            ,   vba.PEITechFee
            ,   vba.PEIRALTransmitterFee
            ,   vba.EROTranFee
            ,   vba.SBFee
            ,   vba.Roll
            ,   null DistributorId
            ,   null CompanyId
            ,   null LocationId
            ,	vba.AgreeBank
            ,	vba.AgreeDate
            ,	null DocPrepFee 
            ,	vba.EFilingFee 
            ,	vba.SystemHold
            from          
                dbo.Refund_Advantage_BankApp vba join efin e on vba.EfinID = e.efinId and vba.UserID = e.userId
            where
                vba.EfinID = isnull(@efinId,vba.EfinID)

    -- Get the SBTPG apps
    if isnull(@bankId,'S') = 'S'
        insert @bapps
            select     
                sba.EfinID
            ,   'TPG' Bank
            ,   'S' BankID
            ,   sba.SBTPG_BankAppID BankAppID
            ,   sba.Delivered
            ,   sba.[Sent]
            ,   sba.DeliveredDate
            ,   sba.SentDate
            ,   sba.Deleted
            ,   sba.UpdatedDate
            ,   sba.SubmittedRecordType
            ,   sba.[Master] appMaster
            ,   case 
                    when isnumeric(sba.OwnersEIN) = 1 then sba.OwnersEIN 
                    else 0 
                end EIN
            ,   sba.OwnersSSN EFINHolderSSN
            ,   sba.OwnersFirstName EFINHolderFirstName
            ,   sba.OwnersLastName EFINHolderLastName
            ,   sba.OwnersDateOfBirth EFINHolderDOB
            ,   sba.CompanyName Company
            ,   sba.OfficeAddress "Address"
            ,   sba.OfficeCity City
            ,   sba.OfficeState "State"
            ,   sba.OfficeZipCode Zip
            ,   sba.OfficePhoneNumber Phone
            ,   sba.OwnersPhoneNumber AlternatePhone
            ,   sba.OfficeFaxNumber Fax
            ,   sba.ManagersEmailAddress Email
            ,   sba.FeeRoutingNumber
            ,   sba.FeeAccountNumber
            ,   sba.FeeAccountType
            ,   sba.PEITechFee
            ,   sba.PEIRALTransmitterFee
            ,   sba.EROTranFee
            ,   sba.SBPrepFee
            ,   sba.Roll
            ,   null DistributorId
            ,   null CompanyId
            ,   null LocationId
            ,	sba.AgreeBank
            ,	sba.AgreeDate
            ,	sba.DocPrepFee 
            ,	null EFilingFee 
            ,	sba.SystemHold
            from          
                dbo.SBTPG_BankApp sba join efin e on sba.EfinID = e.efinId and sba.UserID = e.userId
            where
                sba.EfinID = isnull(@efinId,sba.EfinID)

    -- Get the World Acceptance apps
    if isnull(@bankId,'W') = 'W'
        insert @bapps
            select     
                wba.EfinID
            ,   'TPGW' Bank
            ,   'W' BankID
            ,   wba.SBTPGW_BankAppID BankAppID
            ,   wba.Delivered
            ,   wba.[Sent]
            ,   wba.DeliveredDate
            ,   wba.SentDate
            ,   wba.Deleted
            ,   wba.UpdatedDate
            ,   wba.SubmittedRecordType
            ,   wba.[Master] appMaster
            ,   case 
                    when isnumeric(wba.OwnersEIN) = 1 then wba.OwnersEIN 
                    else 0 
                end EIN
            ,   wba.OwnersSSN EFINHolderSSN
            ,   wba.OwnersFirstName EFINHolderFirstName
            ,   wba.OwnersLastName EFINHolderLastName
            ,   wba.OwnersDateOfBirth EFINHolderDOB
            ,   wba.CompanyName Company
            ,   wba.OfficeAddress "Address"
            ,   wba.OfficeCity City
            ,   wba.OfficeState "State"
            ,   wba.OfficeZipCode Zip
            ,   wba.OfficePhoneNumber Phone
            ,   wba.OwnersPhoneNumber AlternatePhone
            ,   wba.OfficeFaxNumber Fax
            ,   wba.ManagersEmailAddress Email
            ,   wba.FeeRoutingNumber
            ,   wba.FeeAccountNumber
            ,   wba.FeeAccountType
            ,   wba.PEITechFee
            ,   wba.PEIRALTransmitterFee
            ,   wba.EROTranFee
            ,   wba.SBPrepFee
            ,   wba.Roll
            ,   null DistributorId
            ,   null CompanyId
            ,   null LocationId
            ,	wba.AgreeBank
            ,	wba.AgreeDate
            ,	wba.DocPrepFee 
            ,	null EFilingFee 
            ,	wba.SystemHold
            from          
                dbo.SBTPGW_BankApp wba join efin e on wba.EfinID = e.efinId and wba.UserID = e.userId
            where
                wba.EfinID = isnull(@efinId,wba.EfinID)

    -- Get the JTHF apps
    if isnull(@bankId,'J') = 'J'
        insert @bapps
            select     
                jba.EfinID
            ,   'JTHF' Bank
            ,   'J' BankID
            ,   jba.JTHF_BankAppID BankAppID
            ,   jba.Delivered
            ,   jba.[Sent]
            ,   jba.DeliveredDate
            ,   jba.SentDate
            ,   jba.Deleted
            ,   jba.UpdatedDate
            ,   jba.SubmittedRecordType
            ,   jba.[Master] appMaster
            ,   case 
                    when isnumeric(jba.OwnersEIN) = 1 then jba.OwnersEIN 
                    else 0 
                end EIN
            ,   jba.OwnersSSN EFINHolderSSN
            ,   jba.OwnersFirstName EFINHolderFirstName
            ,   jba.OwnersLastName EFINHolderLastName
            ,   jba.OwnersDateOfBirth EFINHolderDOB
            ,   jba.LegalName Company
            ,   jba.OfficeAddress "Address"
            ,   jba.OfficeCity City
            ,   jba.OfficeState "State"
            ,   jba.OfficeZipCode Zip
            ,   jba.OfficePhoneNumber Phone
            ,   jba.OwnersPhoneNumber AlternatePhone
            ,   jba.OfficeFaxNumber Fax
            ,   jba.PrimaryOfficeEMail Email
            ,   jba.FeeRoutingNumber
            ,   jba.FeeAccountNumber
            ,   jba.FeeAccountType
            ,   jba.PEITechFee
            ,   jba.PEIRALTransmitterFee
            ,   jba.EROTranFee
            ,   jba.SBPrepFee
            ,   jba.Roll
            ,   null DistributorId
            ,   null CompanyId
            ,   null LocationId
            ,	jba.AgreeBank
            ,	jba.AgreeDate
            ,	jba.DocPrepFee 
            ,	null EFilingFee 
            ,	jba.SystemHold
            from          
                dbo.JTHF_BankApp jba join efin e on jba.EfinID = e.efinId and jba.UserID = e.userId
            where
                jba.EfinID = isnull(@efinId,jba.EfinID)

    insert @efinRegrMap
        select
            er1.BankCode
        ,   er1.BankAppID
        --,   er1.rowID
        ,   er1.EfinError
        ,   er1.EFINProduct
        ,   er1.EfinStatus
        ,   er1.ErrorDescription
        from
            (
                select
                    er2.BankCode
                ,   er2.BankAppID
                ,   er2.rowID
                ,   er2.EfinError
                ,   er2.EFINProduct
                ,   er2.EfinStatus
                ,   er2.ErrorDescription
                ,   row_number() over ( partition by er2.BankAppID,er2.BankCode order by er2.rowID desc) AS 'RowNumber'    
                from
                    dbo.efin_regr er2 join (
                                            select  
                                                ba1.EfinId
                                            ,   e1.efin
                                            from
                                                @bapps ba1 join dbo.efin e1 on ba1.efinID = e1.EfinID
                                            ) e2 on er2.Efin = e2.Efin
            ) er1
        where
            er1.RowNumber = 1

    insert @bankApp
        select
            e.Account AccountID
        ,   e.UserID
        ,   e.Efin
        ,	e.AgreeFeeOption
        ,	e.AgreeFeeOptionDate
        ,	e.AgreeRushCard
        ,	e.AgreeRushCardDate
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
        ,   ba.appMaster
        ,   ba.EIN
        ,   e.SSN EFINHolderSSN
        ,   e.FirstName EFINHolderFirstName
        ,   e.LastName EFINHolderLastName
        ,   e.DOB EFINHolderDOB
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
        ,   case 
                when ba.BankID = 'A' then e.EROBankFee 
                else 0 
            end EROBankFee
        ,	ba.AgreeBank
        ,	ba.AgreeDate
        ,   ba.SBPrepFee
        ,   ba.Roll
        ,   er.EfinStatus
        ,   er.EfinError ErrorCode
        ,   er.EfinProduct
        ,   case
                when ba.BankID = 'A' then er.ErrorDescription 
                else br.RejectDescription 
            end ErrorDescription
        ,   case
                when brs.Registered is not null then brs.Registered 
                else case 
                        when ba.Delivered = 1 then 'P' 
                        else 'U' 
                     end
            end Registered
        ,   rsd.[Description] AS RegisteredDescription
        ,   e.DistributorId
        ,   e.CompanyId
        ,   e.LocationId
        ,   e.CheckName
        ,   e.SBFeeAll
        ,   isnull(e.HoldFlag, 'N') HoldFlag
        ,   case 
                when ba.BankID = 'R' and er.EFINProduct = 'A' then 'N' 
                else 'Y' 
            end RacsOnly
        ,   c.SBName
        ,   e.AllowMultipleBanks
        ,   brs.LockedAtBank
        ,   e.SelectedBank
        ,   eb.BankName SelectedBankName
        ,   brs.EFINStatus BankStatusCode
        ,   brs.[Description] BankStatusDescription
        ,   e.[Master] efinMaster
        ,   case c.[service_bureau]  
                when 'X' then 1 
                else 0
            end isServiceBureau
        ,   e.RefundAdvantageCardProgram
        ,	ba.DocPrepFee 
        ,	ba.EFilingFee 
        ,	ba.SystemHold
        from
            dbo.efin e join @bapps ba on e.EfinID = ba.EfinID
            left join @efinRegrMap er on ba.BankID = er.BankCode
                and ba.BankAppID = er.BankAppID
            left join dbo.ltblBankRegRejects br ON er.EfinError = br.RejectCode 
                and er.BankCode = br.Bank 
            left join dbo.ltblBankRegistrationStatus brs on brs.BankID = er.BankCode 
                and brs.EFINStatus = er.EfinStatus 
            left join dbo.ltblRegistrationStatusDescription rsd on rsd.Registered = case 
                                                                                        when brs.Registered is not null then brs.Registered 
                                                                                        else case 
                                                                                                when ba.Delivered = 1 then 'P' 
                                                                                                else 'U' 
                                                                                             end
                                                                                    end 
            left join dbCrosslinkGlobal.dbo.customer c ON c.account = e.Account 
            left join dbo.EFINBank eb on eb.EFINBankID = e.SelectedBank





  
select distinct 
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
,   ba.appMaster
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
,   ba.efinMaster
,   ba.isServiceBureau
,   ba.RefundAdvantageCardProgram 
,	ba.DocPrepFee 
,	ba.EFilingFee 
,	ba.SystemHold
from 
    @bankApp ba join (
/*
						select
                            'S' BankId
                        ,   max(sba.SBTPG_BankAppID) BankAppID
                        from    
                            dbo.SBTPG_BankApp sba
                        where
                            sba.Delivered = 1
                        union select
                            'V' BankId
                        ,   max(raba.Refund_Advantage_BankAppID) BankAppID
                        from    
                            dbo.Refund_Advantage_BankApp raba
                        where
                            raba.Delivered = 1
*/
                        select
                            'F' BankId
                        ,   fba.Efin
                        ,   max(fba.BankAppID) BankAppID
                        from    
                            @bankApp fba
                        where
                            fba.BankID = 'F'
                            and fba.Delivered = 1
                        group by
                            fba.Efin
                        union select
                            'R' BankId
                        ,   rba.Efin
                        ,   max(rba.BankAppID) BankAppID
                        from    
                            @bankApp rba
                        where
                            rba.BankID = 'R'
                            and rba.Delivered = 1
                        group by
                            rba.Efin
                        union select
                            'A' BankId
                        ,   aba.Efin
                        ,   max(aba.BankAppID) BankAppID
                        from    
                            @bankApp aba
                        where
                            aba.BankID = 'A'
                            and aba.Delivered = 1
                        group by
                            aba.Efin
                        union select
                            'S' BankId
                        ,   sba.Efin
                        ,   max(sba.BankAppID) BankAppID
                        from    
                            @bankApp sba
                        where
                            sba.BankID = 'S'
                            and sba.Delivered = 1
                        group by
                            sba.Efin
                        union select
                            'W' BankId
                        ,   wba.Efin
                        ,   max(wba.BankAppID) BankAppID
                        from    
                            @bankApp wba
                        where
                            wba.BankID = 'W'
                            and wba.Delivered = 1
                        group by
                            wba.Efin
                        union select
                            'V' BankId
                        ,   raba.Efin
                        ,   max(raba.BankAppID) BankAppID
                        from    
                            @bankApp raba
                        where
                            raba.BankID = 'V'
                            and raba.Delivered = 1
                        group by
                            raba.Efin
                      ) lsba on ba.BankAppID = lsba.BankAppID
        and ba.BankID = lsba.BankId
        and ba.Efin = lsba.Efin

