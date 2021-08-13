
CREATE procedure [dbo].[up_getIRSEFINSummary] --'COLTIM', 33 100 --'GUTXIO'
    @account        varchar(8)
,   @userId     int             = null
as

declare @walletToken char(32)

declare @efin table (
    efinId              int             primary key
,   [address]           varchar(35)
,   city                varchar(22)     
,   efin                int
,   company             varchar(35)
,   userId              int
,	IRSEfinValidation	bit
,	ResultEfinStatus	varchar(1)
,	ResultEfinStatusDate datetime
,	SentDate			datetime
,	HasFiledReturns		bit
,	HasCCAccount		bit
,	HasCCUserEFIN		bit
,	WalletToken			char(32)
)

declare @bapps table (
    EfinID int
,   Bank varchar(50)
,   BankID varchar(1)
,   BankAppID int
,   Delivered bit 
,   DeliveredDate datetime 
,   Deleted bit
,   [Master] int
,   FeeRoutingNumber varchar(9) 
,   FeeAccountNumber varchar(17)
,   EROTranFee int
,   SBPrepFee int
,	SystemHold bit
,	Hidden bit
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
            ,   e.Company
            ,   e.UserID
			,	e.IRSEfinValidation
			,	ev.ResultEfinStatus
			,	ev.ResultEfinStatusDate
			,	ev.SentDate
			,	case when tm.hasfiled is not null then 1
					else 0 
				end
			,	case when ci1.id is not null then 1 else 0 end
			,	case when (ci2.user_id >= 500000 and ci2.id is not null) or (ci3.user_id < 500000 and ci3.id is not null) then 1 else 0 end
			,	case when e.UserID < 500000 then deskw.walletToken else clow.walletToken end 
            from
                dbo.efin e join dbCrosslinkGlobal.dbo.tblUser u on e.UserID = u.[user_id] and e.Account = u.account
                    and e.Account = @account
                    and e.Deleted != 1
                left join dbo.FranchiseOwner fo on u.[user_id] = fo.UserID  
                left join dbo.FranchiseChild fc on u.[user_id] = fc.ChildUserID
				left join dbo.tblEFINValidation ev on e.efin = ev.efin
				left join dbCrosslinkGlobal.dbo.tblCreditCardInfo ci1 on ci1.account_code = e.Account and ci1.user_type = 'A' and ci1.efin = 0 and ci1.user_id = 0 and ci1.primary_card = 1
				left join dbCrosslinkGlobal.dbo.tblCreditCardInfo ci2 on ci2.efin = e.Efin and ci2.user_id = e.UserID and ci2.account_code = e.Account and ci2.primary_card = 1
				left join dbCrosslinkGlobal.dbo.tblCreditCardInfo ci3 on ci3.efin = 0 and ci3.user_id = e.UserID and ci3.account_code = e.Account and ci3.primary_card = 1
				left join dbCrosslinkGlobal.dbo.tblWallet clow on clow.account = e.Account and clow.efin = e.Efin and clow.userId = e.UserID
				left join dbCrosslinkGlobal.dbo.tblWallet deskw on deskw.account = e.Account and deskw.userId = e.UserID and deskw.Efin = 0

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
            ,   e.Company
            ,   e.UserID
			,	e.IRSEfinValidation
			,	ev.ResultEfinStatus
			,	ev.ResultEfinStatusDate
			,	ev.SentDate
			,	case when tm.hasfiled is not null then 1
					else 0
				end
			,	case when ci1.id is not null then 1 else 0 end
			,	case when (ci2.user_id >= 500000 and ci2.id is not null) or (ci3.user_id < 500000 and ci3.id is not null) then 1 else 0 end
			,	case when e.UserID < 500000 then deskw.walletToken else clow.walletToken end 
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
				left join dbo.tblEFINValidation ev on e.efin = ev.efin
				left join dbCrosslinkGlobal.dbo.tblCreditCardInfo ci1 on ci1.account_code = e.Account and ci1.user_type = 'A' and ci1.efin = 0 and ci1.user_id = 0 and ci1.primary_card = 1
				left join dbCrosslinkGlobal.dbo.tblCreditCardInfo ci2 on ci2.efin = e.Efin and ci2.user_id = e.UserID and ci2.account_code = e.Account and ci2.primary_card = 1
				left join dbCrosslinkGlobal.dbo.tblCreditCardInfo ci3 on ci3.efin = 0 and ci3.user_id = e.UserID and ci3.account_code = e.Account and ci3.primary_card = 1
				left join dbCrosslinkGlobal.dbo.tblWallet clow on clow.account = e.Account and clow.efin = e.Efin and clow.userId = e.UserID
				left join dbCrosslinkGlobal.dbo.tblWallet deskw on deskw.account = e.Account and deskw.userId = e.UserID and deskw.Efin = 0

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
		where sba.WorldAcceptance = 0

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


-- main select

    select
        e.efinId EfinID
    ,   upper(@account) Account
    ,   e.[address] [Address]
    ,   e.city City
    --,   case
    --        when brs.Registered is not null then brs.Registered 
    --        else case 
    --                when ba.Delivered = 1 then 'P' 
    --                else 'U' 
    --             end
    --    end Registered
    --,   rsd.[Description] AS RegisteredDescription
    ,   e.efin Efin
    ,   e.company Company
    ,   e.userId UserID
    --,   er.EfinError ErrorCode
    --,   case 
    --        when case
    --                when ba.BankID in ('A', 'V') then er.ErrorDescription 
    --                else br.RejectDescription 
    --            end is not null then case
    --                                    when ba.BankID in ('A', 'V') then er.ErrorDescription 
    --                                    else br.RejectDescription 
    --                                end
    --        else 'Unknown'
    --    end ErrorDescription --C1
 --   ,   isnull(ba.Delivered,0) Delivered --C2
 --   ,   ba.DeliveredDate DeliveredDate --C2
 --   ,   isnull(ba.Deleted,0) Deleted --C3
 --   ,   ba.BankID
 --   ,   ba.Bank
 --   ,   ba.BankAppID
 --   ,   isnull(ba.EROTranFee,0.00) / 100.00 EROTranFee --C5
 --   ,   isnull(ba.SBPrepFee,0.00) / 100.00 SBPrepFee --C6
    ,   isnull(convert(bit,ada.AnyDeliveredApp),0) AnyDeliveredApp
 --   ,	ba.SystemHold
	--,	ba.Hidden
	--,	ba.Master
	--,	ba.FeeRoutingNumber AppRTN
	--,	ba.FeeAccountNumber AppACN
	,	e.IRSEfinValidation
	,	e.ResultEfinStatus
	,	e.ResultEfinStatusDate
	,	e.SentDate
	,	e.HasFiledReturns
	,	e.HasCCAccount
	,	e.HasCCUserEFIN
	,	e.WalletToken

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
                            --,   row_number() over ( partition by ba1.EfinID,ba1.BankID order by ba1.BankAppID desc) AS 'RowNumber'    
                            ,   row_number() over ( partition by ba1.EfinID order by ba1.BankAppID asc) AS 'RowNumber'    
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
       -- left join dbo.ltblBankRegRejects br ON er.EfinError = br.RejectCode 
       --     and er.BankCode = br.Bank 
	        left join dbo.ltblBankRegistrationStatus brs on brs.BankID = er.BankCode 
            and brs.EFINStatus = er.EfinStatus 

       left join ( select Registered, EFINStatus 
					from dbo.ltblBankRegistrationStatus 
					where Registered = 'P' 
					group by Registered, EFINStatus) brs2
						on brs2.EFINStatus = er.EfinStatus

       -- left join dbo.ltblRegistrationStatusDescription rsd on rsd.Registered = case 
       --                                                                             when brs.Registered is not null then brs.Registered 
       --                                                                             else case 
       --                                                                                     when ba.Delivered = 1 then 'P' 
       --                                                                                     else 'U' 
       --                                                                                  end
       --                                                                         end 
        left join dbCrosslinkGlobal.dbo.customer c ON c.account = @account
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

order by
    e.efin
--,   ba.BankAppID




