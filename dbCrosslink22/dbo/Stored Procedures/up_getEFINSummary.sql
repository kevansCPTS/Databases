
CREATE procedure [dbo].[up_getEFINSummary] --'COLTIM', 33 100 --'GUTXIO'
    @account        varchar(8)
,   @userId     int             = null
as

declare @efin table (
    efinId              int             primary key
,   [address]           varchar(35)
,   city                varchar(22)     
,   efin                int
,   efinType            char(1)
,   company             varchar(35)
,   userId              int
,   AllowMultipleBanks  bit
,   SelectedBank        char(1)
,   FeeRoutingNumber varchar(9) 
,   FeeAccountNumber varchar(17)
,	FivePlus			bit
,	IRSEfinValidation	bit
,	HasFiledReturns		bit
)

declare @bapps table (
    EfinID int
,   Bank varchar(50)
,   BankID varchar(1)
,   BankAppID int
,   Delivered bit 
--,   [Sent] bit
,   DeliveredDate datetime 
--,   SentDate datetime
,   Deleted bit
--,   UpdatedDate datetime
--,   SubmittedRecordType char(1) 
,   [Master] int
--,   EIN int
--,   EFINHolderSSN varchar(9) 
--,   EFINHolderFirstName varchar(20)
--,   EFINHolderLastName varchar(20)
--,   EFINHolderDOB datetime
--,   Company varchar(50) 
--,   [Address] varchar(50)
--,   City varchar(50) 
--,   [State] varchar(2)
--,   Zip varchar(10)
--,   Phone varchar(25) 
--,   AlternatePhone varchar(10) 
--,   Fax varchar(10)
--,   Email varchar(75) 
,   FeeRoutingNumber varchar(9) 
,   FeeAccountNumber varchar(17)
--,   FeeAccountType varchar(1)
--,   PEITechFee int 
--,   PEIRALTransmitterFee int 
,   EROTranFee int
,   SBPrepFee int
--,   Roll char(1)
--,   DistributorId int 
--,   CompanyId int
--,   LocationId int 
,	SystemHold bit
,	Hidden bit
)


declare @efinMaster table(
    account                         varchar(8)
,	XLTPGWMasterEfin				int
,   XLRefundAdvMasterEfin           int 
,   XLRefundoMasterEfin             int
,	XLRepublicMasterEfin			int
,   XLSBTPGMasterEfin               int
,	MSOTPGWMasterEfin				int
,   MSORefundAdvMasterEfin          int
,   MSORefundoMasterEfin            int
,	MSORepublicMasterEfin			int
,   MSOSBTPGMasterEfin              int
)

set nocount on

    -- Populate the EFIN data
    -- Depending on the supplied parameters, linmit the returned users.
    
    -- If the account is the only paramater provided, return only the users 
    -- that are not franchise owners or children for the account.   
    if (@userId is null)
        insert @efin
            select
                e.EfinID
            ,   e.[Address]
            ,   e.City
            ,   e.Efin
            ,   e.EFINType
            ,   e.Company
            ,   e.UserID
            ,   e.AllowMultipleBanks
            ,   e.SelectedBank
			,   e.FeeRoutingNumber
			,   e.FeeAccountNumber
			,	e.FivePlus
			,	e.IRSEfinValidation
			,	case when tm.hasfiled is not null then 1
					else 0
				end
            from
                dbo.efin e join dbCrosslinkGlobal.dbo.tblUser u on e.UserID = u.[user_id] and e.Account = u.account
                    and e.Account = @account
                    and e.Deleted != 1
                left join dbo.FranchiseOwner fo on u.[user_id] = fo.UserID  
                left join dbo.FranchiseChild fc on u.[user_id] = fc.ChildUserID
				left join (
						    -- Find if any returns have been filed
		                    select
								efin, 
							    count(tmt.efin) hasfiled
							from
								tblTaxmast tmt
							group by
								tmt.efin
						) tm on e.efin = tm.efin
            where
                fo.UserID is null
                and fc.ParentUserID is null
    -- Otherwise, get ONLY the provided user and it's franchise children.
    else
        insert @efin
            select
                e.EfinID
            ,   e.[Address]
            ,   e.City
            ,   e.Efin
            ,   e.EFINType
            ,   e.Company
            ,   e.UserID
            ,   e.AllowMultipleBanks
            ,   e.SelectedBank
			,   e.FeeRoutingNumber
			,   e.FeeAccountNumber
			,	e.FivePlus
			,	e.IRSEfinValidation
			,	case when tm.hasfiled is not null then 1
					else 0
				end
            from
                dbo.efin e join dbCrosslinkGlobal.dbo.tblUser u on e.UserID = u.[user_id] and e.Account = u.account
                    and e.Account = @account
                    and e.Deleted != 1
                join (
                        select distinct
                            ChildUserID UserId
                        from
                            FranchiseChild 
                        where
                            ParentUserID = @userId
                        union select
                            UserID
                        from
                            FranchiseOwner fo
                        where
                            UserID = @userId
                        union select
                            user_id UserID
                        from
                            tbluser us
                        where
                            user_id = @userId
                      ) fou on u.[user_id] = fou.UserId
				left join (
							-- Find if any returns have been filed
							select
								efin, 
								count(tmt.efin) hasfiled
							from
								tblTaxmast tmt
							group by
								tmt.efin
						) tm on e.efin = tm.efin


    -- Get the Master EFIN information from the bank apps for the selected account
    insert @efinMaster
        exec up_getAccountMasterEfin @account


    -- Get the Refund Advantage apps
    insert @bapps
        select     
            vba.EfinID
        ,   'Ref Adv' Bank
        ,   'V' BankID
        ,   vba.Refund_Advantage_BankAppID BankAppID
        ,   vba.Delivered
		,	vba.DeliveredDate
        ,   vba.Deleted
		,	vba.Master
		,	vba.FeeRoutingNumber
		,	vba.FeeAccountNumber
        ,   vba.EROTranFee
        ,   vba.SBFee
        ,	vba.SystemHold
		,	vba.Hidden
        from          
            dbo.Refund_Advantage_BankApp vba join @efin e on vba.EfinID = e.efinId and vba.UserID = e.userId

    -- Get the SBTPG apps
    insert @bapps
        select     
            sba.EfinID
        ,   'TPG' Bank
        ,   'S' BankID
        ,   sba.SBTPG_BankAppID BankAppID
        ,   sba.Delivered
		,	sba.DeliveredDate
        ,   sba.Deleted
		,	sba.Master
		,	sba.FeeRoutingNumber
		,	sba.FeeAccountNumber
        ,   sba.EROTranFee
        ,   sba.SBPrepFee
        ,	sba.SystemHold
		,	sba.Hidden
        from          
            dbo.SBTPG_BankApp sba join @efin e on sba.EfinID = e.efinId and sba.UserID = e.userId
--		where sba.WorldAcceptance = 0

     -- Get the World Acceptance apps
    insert @bapps
        select     
            wba.EfinID
        ,   'TPGW' Bank
        ,   'W' BankID
        ,   wba.SBTPGW_BankAppID BankAppID
        ,   wba.Delivered
		,	wba.DeliveredDate
        ,   wba.Deleted
		,	wba.Master
		,	wba.FeeRoutingNumber
		,	wba.FeeAccountNumber
        ,   wba.EROTranFee
        ,   wba.SBPrepFee
        ,	wba.SystemHold
		,	wba.Hidden
        from          
            dbo.SBTPGW_BankApp wba join @efin e on wba.EfinID = e.efinId and wba.UserID = e.userId

    -- Get the Refundo apps
    insert @bapps
        select     
            rba.EfinID
        ,   'Refundo' Bank
        ,   'F' BankID
        ,   rba.Refundo_BankAppID BankAppID
        ,   rba.Delivered
		,	rba.DeliveredDate
        ,   rba.Deleted
		,	rba.Master
		,	rba.FeeRoutingNumber
		,	rba.FeeAccountNumber
        ,   rba.EROTranFee
        ,   rba.SBPrepFee
        ,	rba.SystemHold
		,	rba.Hidden
        from         
            dbo.Refundo_BankApp rba join @efin e on rba.EfinID = e.efinId and rba.UserID = e.userId
            
    -- Get the Republic apps
    insert @bapps
        select     
            rba.EfinID
        ,   'Republic' Bank
        ,   'R' BankID
        ,   rba.Republic_BankAppID BankAppID
        ,   rba.Delivered
		,	rba.DeliveredDate
        ,   rba.Deleted
		,	rba.Master
		,	rba.FeeRoutingNumber
		,	rba.FeeAccountNumber
        ,   rba.EROTranFee
        ,   rba.SBPrepFee
        ,	rba.SystemHold
		,	rba.Hidden
        from         
            dbo.Republic_BankApp rba join @efin e on rba.EfinID = e.efinId and rba.UserID = e.userId

    select
        e.efinId EfinID
    ,   upper(@account) Account
    ,   e.[address] [Address]
    ,   e.city City
    ,   case
            when brs.Registered is not null then brs.Registered 
            else case 
                    when ba.Delivered = 1 then 'P' 
                    else 'U' 
                 end
        end Registered
    ,   rsd.[Description] AS RegisteredDescription
    ,   e.efin Efin
    ,   e.efinType EfinType
    ,   e.company Company
    ,   e.userId UserID
    ,   er.EfinError ErrorCode
    ,   case 
            when case
                    when ba.BankID in ('A', 'V') then er.ErrorDescription 
                    else br.RejectDescription 
                end is not null then case
                                        when ba.BankID in ('A', 'V') then er.ErrorDescription 
                                        else br.RejectDescription 
                                    end
            else 'Unknown'
        end ErrorDescription --C1
    ,   isnull(ba.Delivered,0) Delivered --C2
    ,   ba.DeliveredDate DeliveredDate --C2
    ,   isnull(ba.Deleted,0) Deleted --C3
    ,   ba.BankID
    ,   ba.Bank
    ,   ba.BankAppID
    ,   isnull(e.AllowMultipleBanks,0) AllowMultipleBanks  --C4   
    ,   e.SelectedBank
    ,   eb.BankName SelectedBankName
    ,   isnull(ba.EROTranFee,0.00) / 100.00 EROTranFee --C5
    ,   isnull(ba.SBPrepFee,0.00) / 100.00 SBPrepFee --C6
    ,   isnull(convert(bit,ada.AnyDeliveredApp),0) AnyDeliveredApp
    ,	ba.SystemHold
	,	ba.Hidden
	,	ba.Master
	,	ba.FeeRoutingNumber AppRTN
	,	ba.FeeAccountNumber AppACN
	,	e.FeeRoutingNumber EfinRTN
	,	e.FeeAccountNumber EfinACN
	,	e.FivePlus
	,	e.IRSEfinValidation
	,	e.HasFiledReturns
    ,   em.XLRefundAdvMasterEfin            
    ,   em.XLRefundoMasterEfin             
    ,   em.XLSBTPGMasterEfin               
    ,   em.XLTPGWMasterEfin               
    ,   em.MSORefundAdvMasterEfin          
    ,   em.MSORefundoMasterEfin            
    ,   em.MSOSBTPGMasterEfin              
    ,   em.MSOTPGWMasterEfin              
	from
        @efin e left join (
                            select
                                ba1.EfinID
                            ,   ba1.BankAppID    
                            ,   ba1.BankID    
                            ,   ba1.Bank   
                            ,   ba1.EROTranFee   
                            ,   ba1.SBPrepFee
                            ,   ba1.Deleted
							,	ba1.Master
                            ,   ba1.Delivered
							,	ba1.DeliveredDate
                            ,	ba1.SystemHold
							,	ba1.Hidden
							,	ba1.FeeRoutingNumber
							,	ba1.FeeAccountNumber
                            ,   row_number() over ( partition by ba1.EfinID,ba1.BankID order by ba1.BankAppID desc) AS 'RowNumber'    
                            from        
                                @bapps ba1 
                            where
                                ba1.Deleted = 0
                        ) ba on e.EfinID = ba.EfinID
            and ba.RowNumber = 1
        left join (
                select
                    er1.BankCode
                ,   er1.BankAppID
                ,   MAX(er1.rowID) RegrRowID
                from
                    --dbo.efin_regr er1
                    @bapps ba2 join dbo.efin_regr er1 on ba2.BankId = er1.BankCode
                        and ba2.BankAppID = er1.BankAppID
                group by
                    er1.BankCode
                ,   er1.BankAppID) lr ON ba.BankID = lr.BankCode
            and ba.BankAppID = lr.BankAppID
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
        left join dbCrosslinkGlobal.dbo.customer c ON c.account = @account
        left join dbo.EFINBank eb on eb.EFINBankID = e.SelectedBank
        left join (
                    -- Find if any bank apps are delivered for this EFIN
                    select
                        ba2.EfinID   
                    ,   max(isnull(convert(tinyint,ba2.delivered),0)) AnyDeliveredApp
                    from
                        @bapps ba2
                    where
                        ba2.Deleted = 0
                    group by
                        ba2.EfinID
        ) ada on e.efinId = ada.EfinID
        left join @efinMaster em on em.account = @account
order by
    e.efin
,   ba.BankAppID




