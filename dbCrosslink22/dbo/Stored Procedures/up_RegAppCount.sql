
/************************************************************************************************
Name: up_RegAppCount

Purpose: Procedure to replace the count calls to the "vwRegistrationApplication" view. This procedure 
conditionally queries all the bank application tables, depending on the value of the "@bankId" parameter. 
This procedure requires the efin or efin Id and, as a result, is much more efficient than the view.  


Called By:

Parameters: 
 1 @efin int
 2 @bankId  char(1) = null
 3 @efinid  int     = null

Result Codes:
 0 success

Author: Ken Evans 09/28/2012

Changes/Update:
    
	JW - 07/23/2013:
		Removed the MultiOffice field


**************************************************************************************************/
CREATE procedure [dbo].[up_RegAppCount] --null, 'A', 3248
    @efin           int                 =   null
,   @bankId         varchar(5)          =   null
,   @efinid         int                 =   null
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
,   [Master] int
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
)


declare @output table (
    AccountId varchar(8)
,   UserId int
,   Efin int
,   EfinID int
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
,   [Master] int
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
,   EROBankFee int
,   SBPrepFee int
,   Roll char(1)
,   EfinStatus varchar(1)  
,   ErrorCode varchar(50) 
,   EfinProdcut varchar(1)  
,   ErrorDescription varchar(350) 
,   Registered varchar(1)  
,   RegisteredDescription varchar(25) 
,   DistributorId int 
,   CompanyId int
,   LocationId int 
,   CheckName varchar(15)
,   SBFeeAll varchar(1) 
,   HoldFlag varchar(1) 
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

    -- Get the efinId for the provided efin
    if (@efinid is null)
        select
            @efinId = e.EfinID
        from
            dbo.efin e
        where
            e.Efin = @efin

    if(@efinid is null)
        begin
            print 'You need to pass in either an EFIN or an EFIN_ID to process the bank app data.'
            return 1
        end



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
            ,   sba.[Master]
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
            from          
                dbo.SBTPG_BankApp sba
            where
                sba.EfinID = @efinId
			and sba.WorldAcceptance = 0

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
            ,   wba.[Master]
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
            from          
                dbo.SBTPGW_BankApp wba
            where
                wba.EfinID = @efinId

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
            ,   rba.SubmittedRecordType
            ,   rba.[Master]
            ,   0 EIN
            ,   rba.OwnerSSN EFINHolderSSN
            ,   rba.EfinOwnerFirstName EFINHolderFirstName
            ,   rba.EfinOwnerLastName EFINHolderLastName
            ,   rba.OwnerDOB EFINHolderDOB
            ,   rba.OfficeName Company
            ,   rba.OfficePhysicalStreet "Address"
            ,   rba.OfficePhysicalCity City
            ,   rba.OfficePhysicalState "State"
            ,   rba.OfficePhysicalZip Zip
            ,   rba.OfficePhoneNumber Phone
            ,   rba.CellPhoneNumber AlternatePhone
            ,   rba.FaxNumber Fax
            ,   rba.EmailAddress Email
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
            from         
                dbo.Republic_BankApp rba 
            where
                rba.EfinID = @efinId

    -- Get the Refundo apps
    if isnull(@bankId,'F') = 'F'
        insert @bapps
            select     
                rba.EfinID
            ,   'Refundo' Bank
            ,   'F' BankID
            ,   rba.Refundo_BankAppID BankAppID
            ,   rba.Delivered
            ,   rba.[Sent]
            ,   rba.DeliveredDate
            ,   rba.SentDate
            ,   rba.Deleted
            ,   rba.UpdatedDate
            ,   rba.SubmittedRecordType
            ,   rba.[Master]
            ,   0 EIN
            ,   rba.OwnerSSN EFINHolderSSN
            ,   rba.EfinOwnerFirstName EFINHolderFirstName
            ,   rba.EfinOwnerLastName EFINHolderLastName
            ,   rba.OwnerDOB EFINHolderDOB
            ,   rba.OfficeName Company
            ,   rba.OfficePhysicalStreet "Address"
            ,   rba.OfficePhysicalCity City
            ,   rba.OfficePhysicalState "State"
            ,   rba.OfficePhysicalZip Zip
            ,   rba.OfficePhoneNumber Phone
            ,   rba.CellPhoneNumber AlternatePhone
            ,   rba.FaxNumber Fax
            ,   rba.EmailAddress Email
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
            from         
                dbo.Refundo_BankApp rba 
            where
                rba.EfinID = @efinId

    -- Get the Refund Advantage apps
    if isnull(@bankId,'V') = 'V'
        insert @bapps
            select     
                vba.EfinID
            ,   'Ref Adv' Bank
            ,   'R' BankID
            ,   vba.Refund_Advantage_BankAppID BankAppID
            ,   vba.Delivered
            ,   vba.[Sent]
            ,   vba.DeliveredDate
            ,   vba.SentDate
            ,   vba.Deleted
            ,   vba.UpdatedDate
            ,   '' SubmittedRecordType
            ,   vba.[Master]
            ,    0 EIN
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
            from         
                dbo.Refund_Advantage_BankApp vba 
            where
                vba.EfinID = @efinId
            

    insert @output
        select
            e.Account AccountID
        ,   e.UserID
        ,   e.Efin
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
        ,   case 
                when ba.BankID = 'A' then e.EROBankFee 
                else 0 
            end EROBankFee
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
        from
            dbo.efin e join @bapps ba on e.EfinID = ba.EfinID
            left join (
                        select
                            er1.BankCode
                        ,   er1.BankAppID
                        ,   er1.rowID
                        ,   row_number() over ( partition by er1.BankCode, er1.BankAppID order by er1.rowID desc) RowNumber
                        from
                            dbo.efin_regr er1
                        ) lr ON lr.BankCode = ba.BankID 
                and lr.BankAppID = ba.BankAppID
                and isnull(lr.RowNumber,1) = 1 
            left join dbo.efin_regr er ON lr.rowID = er.rowID 
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



select
    count(*) C1
from 
    @output o join (
                    select
                        o1.BankID
                    ,   o1.BankAppID
                    ,   row_number() over ( partition by o1.BankID, o1.Efin order by o1.BankAppID desc) RowNumber    
                    from    
                        @output o1 join dbo.ltblRegistrationStatusDescription rsd1 on o1.Registered = rsd1.Registered
                            and rsd1.SendToEFINMaster = 1
                    ) o2 on o.BankID = o2.BankID
        and o.BankAppID = o2.BankAppID
        and o2.RowNumber = 1
        and o.Registered = 'A'
        and o.Deleted != 1
    





/*

SELECT     
    vwBankApplication_1.BankID
, vwBankApplication_1.Efin
, MAX(vwBankApplication_1.BankAppID) AS BankAppID
FROM          
    dbo.vwBankApplication AS vwBankApplication_1 WITH (nolock) INNER JOIN
                                                   dbo.ltblRegistrationStatusDescription AS RegStatus WITH (nolock) ON RegStatus.Registered = vwBankApplication_1.Registered
                            WHERE      (RegStatus.SendToEFINMaster = 1)
                            GROUP BY vwBankApplication_1.BankID, vwBankApplication_1.Efin


*/


