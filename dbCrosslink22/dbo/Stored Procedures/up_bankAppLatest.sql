

/************************************************************************************************
Name: up_bankAppLatest
Purpose: Procedure to replace the "dbo.vwLatestBankApplication" view. This procedure conditionally queries all the bank application 
tables, depending on the value of the "@bankId" parameter. This procedure requires the efin and, as a result, is 
much more efficient than the view. It returns the latest bank app from each of the current banks for the given EFIN. 



Called By:

Parameters: 
 1 @efin int
 2 @bankId  char(1) = null
 3 @efinid  int     = null

Result Codes:
 0 success

Author: Ken Evans 06/27/2012

Changes/Update:
    
    KJE - 07/27/2012:
        Added the optional parameter for the efin_id to be passed instead of the efin. 
 
    KJE - 07/30/2012:
        Updated the column widths on the temp bank app table to allow for long values from Advent. 

    KJE - 11/02/2012:
        Modified the latest app selection logic as follows:
            When a bank Id is provided,  bank app with the greatest AppId is returned.
            When no bank is provided, that last modified app is returned.  

    JW - 5/13/2013:
		Added AgreeBank, AgreeDate, AgreeFeeOption, AgreeFeeOptionDate, AgreeRushCard, AgreeRushCardDate columns

	JW - 07/23/2013:
		Removed the MultiOffice field

	JW - 06/18/2014
		Added Refundo

	JW - 09/11/2014
		Added FeeAccountName

	JW - 12/15/2015
		Added World Acceptance

**************************************************************************************************/
CREATE procedure [dbo].[up_bankAppLatest] --null,'A',308104 ,null,--, 'A'--606087, 'A'--549489, null
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
,   [MailAddress] varchar(50)
,   MailCity varchar(50) 
,   [MailState] varchar(2)
,   MailZip varchar(10)
,   [ShipAddress] varchar(50)
,   ShipCity varchar(50) 
,   [ShipState] varchar(2)
,   ShipZip varchar(10)
,   Phone varchar(25) 
,   AlternatePhone varchar(10) 
,   Fax varchar(10)
,   Email varchar(75) 
,   FeeRoutingNumber varchar(9) 
,   FeeAccountNumber varchar(17)
,   FeeAccountType varchar(1)
,   FeeAccountName varchar(35)
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
,	SystemHold	bit
,	NetTranFee int
,	CPTSAdminFee int
,	EFFee int
,	NetEFFee int
,	CPTSAdminEFFee int
,	EFFeeAll char(1)
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
            ,   rba.[Master]
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
			,	rba.MailingAddress MailAddress
            ,   rba.MailingCity MailCity
            ,   rba.MailingState MailState
            ,   rba.MailingZip MailZip
			,	rba.FulfillmentShippingStreet ShipAddress
			,	rba.FulfillmentShippingCity ShipCity
			,	rba.FulfillmentShippingState ShipState
			,	rba.FulfillmentShippingZip ShipZip
            ,   rba.OfficePhoneNumber Phone
            ,   '' AlternatePhone
            ,   rba.FaxNumber Fax
            ,   '' Email
            ,   rba.FeeRoutingNumber
            ,   rba.FeeAccountNumber
            ,   rba.FeeAccountType
			,	rba.FeeAccountName
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
			,	rba.NetTranFee
			,	rba.CPTSAdminFee
			,	rba.EFFee
			,	rba.NetEFFee
			,	rba.CPTSAdminEFFee
			,	rba.EFFeeAll
            from          
                dbo.Republic_BankApp rba join efin e on rba.EfinID = e.efinId and rba.UserID = e.userId
            where
                rba.EfinID = @efinId

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
            ,   fba.[Master]
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
			,	fba.MailingAddress MailAddress
            ,   fba.MailingCity MailCity
            ,   fba.MailingState MailState
            ,   fba.MailingZip MailZip
			,	fba.FulfillmentShippingStreet ShipAddress
			,	fba.FulfillmentShippingCity ShipCity
			,	fba.FulfillmentShippingState ShipState
			,	fba.FulfillmentShippingZip ShipZip
            ,   fba.OfficePhoneNumber Phone
            ,   '' AlternatePhone
            ,   fba.FaxNumber Fax
            ,   '' Email
            ,   fba.FeeRoutingNumber
            ,   fba.FeeAccountNumber
            ,   fba.FeeAccountType
			,	'' FeeAccountName
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
            ,	fba.DocPrepFee
            ,	null EFilingFee
            ,	fba.SystemHold
			,	fba.NetTranFee
			,	fba.CPTSAdminFee
			,	fba.EFFee
			,	fba.NetEFFee
			,	fba.CPTSAdminEFFee
			,	fba.EFFeeAll
            from          
                dbo.Refundo_BankApp fba join efin e on fba.EfinID = e.efinId and fba.UserID = e.userId
            where
                fba.EfinID = @efinId

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
            ,   vba.[Master]
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
			,	vba.MailingAddressStreet MailAddress
            ,   vba.MailingAddressCity MailCity
            ,   vba.MailingAddressState MailState
            ,   vba.MailingAddressZip MailZip
			,	vba.ShippingAddressStreet ShipAddress
			,	vba.ShippingAddressCity ShipCity
			,	vba.ShippingAddressState ShipState
			,	vba.ShippingAddressZip ShipZip

            ,   vba.OfficePhone Phone
            ,   '' AlternatePhone
            ,   vba.OfficeFax Fax
            ,   '' Email
            ,   vba.FeeRoutingNumber
            ,   vba.FeeAccountNumber
            ,   vba.FeeAccountType
			,	'' FeeAccountName
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
			,	vba.NetTranFee
			,	vba.CPTSAdminFee
			,	vba.EFFee
			,	vba.NetEFFee
			,	vba.CPTSAdminEFFee
			,	vba.EFFeeAll
            from          
                dbo.Refund_Advantage_BankApp vba join efin e on vba.EfinID = e.efinId and vba.UserID = e.userId
            where
                vba.EfinID = @efinId

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
			,	'' MailAddress
            ,   '' MailCity
            ,   '' MailState
            ,   '' MailZip
			,	sba.ShippingAddress ShipAddress
			,	sba.ShippingCity ShipCity
			,	sba.ShippingState ShipState
			,	sba.ShippingZipCode ShipZip
            ,   sba.OfficePhoneNumber Phone
            ,   sba.OwnersPhoneNumber AlternatePhone
            ,   sba.OfficeFaxNumber Fax
            ,   sba.ManagersEmailAddress Email
            ,   sba.FeeRoutingNumber
            ,   sba.FeeAccountNumber
            ,   sba.FeeAccountType
			,	'' FeeAccountName
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
			,	sba.NetTranFee
			,	sba.CPTSAdminFee
			,	sba.EFFee
			,	sba.NetEFFee
			,	sba.CPTSAdminEFFee
			,	sba.EFFeeAll
            from          
                dbo.SBTPG_BankApp sba join efin e on sba.EfinID = e.efinId and sba.UserID = e.userId
            where
                sba.EfinID = @efinId

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
			,	'' MailAddress
            ,   '' MailCity
            ,   '' MailState
            ,   '' MailZip
			,	wba.ShippingAddress ShipAddress
			,	wba.ShippingCity ShipCity
			,	wba.ShippingState ShipState
			,	wba.ShippingZipCode ShipZip
            ,   wba.OfficePhoneNumber Phone
            ,   wba.OwnersPhoneNumber AlternatePhone
            ,   wba.OfficeFaxNumber Fax
            ,   wba.ManagersEmailAddress Email
            ,   wba.FeeRoutingNumber
            ,   wba.FeeAccountNumber
            ,   wba.FeeAccountType
			,	'' FeeAccountName
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
			,	wba.NetTranFee
			,	wba.CPTSAdminFee
			,	wba.EFFee
			,	wba.NetEFFee
			,	wba.CPTSAdminEFFee
			,	wba.EFFeeAll
            from          
                dbo.SBTPGW_BankApp wba join efin e on wba.EfinID = e.efinId and wba.UserID = e.userId
            where
                wba.EfinID = @efinId

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
    ,   ba.[Master]
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
	,	ba.MailAddress
	,	ba.MailCity
	,	ba.MailState
	,	ba.MailZip
	,	ba.ShipAddress
	,	ba.ShipCity
	,	ba.ShipState
	,	ba.ShipZip
    ,   ba.Phone
    ,   ba.AlternatePhone
    ,   ba.Fax
    ,   ba.Email
    ,   ba.FeeRoutingNumber
    ,   ba.FeeAccountNumber
    ,   ba.FeeAccountType
	,	ba.FeeAccountName
    ,   ba.PEITechFee
    ,   ba.PEIRALTransmitterFee
    ,   ba.EROTranFee
    ,   case 
            when ba.BankID IN ('A', 'F') then e.EROBankFee 
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
    ,	ba.DocPrepFee
    ,	ba.EFilingFee
    ,	ba.SystemHold
	,	t.NonFinancialTransmitterFee
	,	ba.NetTranFee
	,	ba.CPTSAdminFee
	,	ba.EFFee
	,	ba.NetEFFee
	,	ba.CPTSAdminEFFee
	,	ba.EFFeeAll
    from
        dbo.efin e join @bapps ba on e.EfinID = ba.EfinID
            and ba.Deleted = 0
            and ba.BankID = isnull(@bankId,ba.BankID)
        join (
                select top 1
                    ba1.BankAppID BankAppID 
                from    
                    @bapps ba1
                where
                    ba1.BankID = isnull(@bankId,ba1.BankID)
                    and ba1.Deleted = 0
                order by
                    case when @bankId is not null then ba1.BankAppID end desc
                ,   case when @bankId is null then ba1.UpdatedDate end desc
                
               /*
                select
                    max(ba1.BankAppID) BankAppID    
                from    
                    @bapps ba1
                where
                    ba1.BankID = isnull(@bankId,ba1.BankID)
                    and ba1.Deleted = 0
                group by
                    ba1.BankID
                */         
                ) lba on ba.BankAppID = lba.BankAppID
        left join (
                select
                    er1.BankCode
                ,   er1.BankAppID
                ,   MAX(er1.rowID) RegrRowID
                from
                    dbo.efin_regr er1
                group by
                    er1.BankCode
                ,   er1.BankAppID) lr ON lr.BankCode = ba.BankID 
            and lr.BankAppID = ba.BankAppID 
        left join dbo.efin_regr er ON lr.RegrRowID = er.rowID 
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
		left join dbCrosslinkGlobal.dbo.AccountTransmitterFeePrice t ON t.Account = e.Account and t.season = dbo.getXlinkSeason()
        left join dbo.EFINBank eb on eb.EFINBankID = e.SelectedBank




