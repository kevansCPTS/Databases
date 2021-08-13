
CREATE procedure [dbo].[up_getEFINGrid] --'COLTIM', 33 100 --'GUTXIO'
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
,	FivePlus			bit
,	IRSEfinValidation	bit
,	ResultEfinStatus	varchar(1)
,	ResultEfinStatusDate datetime
,	SentDate			datetime
,	UserHold			char(1)
,	EfinHold			char(1)
,	HasFiledReturns		bit
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
,   EROTranFee int
,   SBPrepFee int
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
			,	e.FivePlus
			,	e.IRSEfinValidation
			,	ev.ResultEfinStatus
			,	ev.ResultEfinStatusDate
			,	ev.SentDate
			,	u.hold_flag
			,	e.HoldFlag
			,	case when tm.hasfiled is not null then 1
					else 0
				end
            from
                dbo.efin e join dbCrosslinkGlobal.dbo.tblUser u on e.UserID = u.[user_id]
                    and e.Account = @account
                    and e.Deleted != 1
				left join dbo.tblEFINValidation ev on e.efin = ev.efin
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
			,	e.FivePlus
			,	e.IRSEfinValidation
			,	ev.ResultEfinStatus
			,	ev.ResultEfinStatusDate
			,	ev.SentDate
			,	u.hold_flag
			,	e.HoldFlag
			,	case when tm.hasfiled is not null then 1
					else 0
				end
            from
                dbo.efin e join dbCrosslinkGlobal.dbo.tblUser u on e.UserID = u.[user_id]
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
        ,   rba.EROTranFee
        ,   rba.SBPrepFee
        ,	rba.SystemHold
		,	rba.Hidden
        from         
            dbo.Republic_BankApp rba join @efin e on rba.EfinID = e.efinId and rba.UserID = e.userId

    select
		e.efinId EfinID --OK
    ,   upper(@account) Account --OK
    ,   e.[address] [Address] --OK
    ,   e.city City --OK
    ,   e.efin Efin --OK
    ,   e.efinType EfinType --OK
    ,   e.company Company --OK
    ,   e.userId UserID --OK
	,	isnull(e.UserHold,'N') UserHold
    ,   e.SelectedBank --OK
    ,   case when eb.bankname = 'Refund Advantage' then 'Ref Adv' else eb.BankName end  SelectedBankName --OK
	,	e.FivePlus -- is deprcated but OK to leave
	,	e.IRSEfinValidation --OK
	,	e.ResultEfinStatus
	,	e.ResultEfinStatusDate
	,	e.SentDate EfinSentDate
	,	isnull(e.EfinHold,'N') EfinHold
	,	e.HasFiledReturns --OK
--    ,   isnull(ba.Deleted,0) Deleted --C3
    ,   isnull(e.AllowMultipleBanks,0) AllowMultipleBanks  --C4   --OK
    ,   isnull(convert(bit,ada.AnyDeliveredApp),0) AnyDeliveredApp --OK
    --,   isnull(convert(bit,tpgada.AnyDeliveredApp),0) AnyTPGDeliveredApp
    --,   isnull(convert(bit,worldada.AnyDeliveredApp),0) AnyWorldDeliveredApp
    --,   isnull(convert(bit,raada.AnyDeliveredApp),0) AnyRADeliveredApp
    --,   isnull(convert(bit,republicada.AnyDeliveredApp),0) AnyRepublicDeliveredApp
    --,   isnull(convert(bit,refundoada.AnyDeliveredApp),0) AnyRefundoDeliveredApp
	,   isnull(sbtpgapp.BankAppID, 0) TPGBankAppID
	,   isnull(worldapp.BankAppID, 0) WorldBankAppID
	,   isnull(raapp.BankAppID, 0) RABankAppID
	,   isnull(republicapp.BankAppID, 0) RepublicBankAppID
	,   isnull(refundoapp.BankAppID, 0) RefundoBankAppID
    ,   case
            when sbtpgbrs.Registered is not null then sbtpgbrs.Registered 
            else case 
                    when sbtpgapp.Delivered = 1 then 'P' 
                    else case when sbtpgapp.bankappID is not null then 'U' end
                 end
        end TPGRegistered

		    ,   case
            when worldbrs.Registered is not null then worldbrs.Registered 
            else case 
                    when worldapp.Delivered = 1 then 'P' 
                    else case when worldapp.bankappID is not null then 'U' end
                 end
        end WorldRegistered
    ,   case
            when rabrs.Registered is not null then rabrs.Registered 
            else case 
                    when raapp.Delivered = 1 then 'P' 
                    else case when raapp.bankappID is not null then 'U' end
                 end
        end RARegistered
    ,   case
            when republicbrs.Registered is not null then republicbrs.Registered 
            else case 
                    when republicapp.Delivered = 1 then 'P' 
                    else case when republicapp.bankappID is not null then 'U' end
                 end
        end RepublicRegistered
    ,   case
            when refundobrs.Registered is not null then refundobrs.Registered 
            else case 
                    when refundoapp.Delivered = 1 then 'P' 
                    else case when refundoapp.bankappID is not null then 'U' end
                 end
        end RefundoRegistered
	,	case when tpgada.AnyDeliveredApp = 1 and sbtpgrsd.Registered = 'U' then 'Resubmit' else sbtpgrsd.[Description] end TPGRegisteredDescription
	,	case when worldada.AnyDeliveredApp = 1 and worldrsd.Registered = 'U' then 'Resubmit' else worldrsd.[Description] end WorldRegisteredDescription
	,	case when raada.AnyDeliveredApp = 1 and rarsd.Registered = 'U' then 'Resubmit' else rarsd.[Description] end RARegisteredDescription
	,	case when republicada.AnyDeliveredApp = 1 and republicrsd.Registered = 'U' then 'Resubmit' else republicrsd.[Description] end RepublicRegisteredDescription
	,	case when refundoada.AnyDeliveredApp = 1 and refundorsd.Registered = 'U' then 'Resubmit' else refundorsd.[Description] end RefundoRegisteredDescription
	,	sbtpger.EfinError TPGErrorCode
	,	worlder.EfinError WorldErrorCode
	,	raer.EfinError RAErrorCode
	,	republicer.EfinError RepublicErrorCode
	,	refundoer.EfinError RefundoErrorCode
    ,   isnull(sbtpgbr.RejectDescription, 'Unknown') TPGErrorDescription --C1
    ,   isnull(worldbr.RejectDescription, 'Unknown') WorldErrorDescription --C1
    ,   isnull(rabr.RejectDescription, 'Unknown') RAErrorDescription --C1
    ,   isnull(republicbr.RejectDescription, 'Unknown') RepublicErrorDescription --C1
    ,   isnull(refundobr.RejectDescription, 'Unknown') RefundoErrorDescription --C1
	,	isnull(sbtpgapp.Delivered,0) TPGDelivered
	,   sbtpgapp.DeliveredDate as TPGDeliveredDate
	,	isnull(worldapp.Delivered,0) WorldDelivered
	,   worldapp.DeliveredDate as WorldDeliveredDate
	,	isnull(raapp.Delivered,0) RADelivered
	,   raapp.DeliveredDate as RADeliveredDate
	,	isnull(republicapp.Delivered,0) RepublicDelivered
	,   republicapp.DeliveredDate as RepublicDeliveredDate
	,	isnull(refundoapp.Delivered,0) RefundoDelivered
	,   refundoapp.DeliveredDate as RefundoDeliveredDate
	,	sbtpgapp.SystemHold TPGSystemHold
	,	worldapp.SystemHold WorldSystemHold
	,	raapp.SystemHold RASystemHold
	,	republicapp.SystemHold RepublicSystemHold
	,	refundoapp.SystemHold RefundoSystemHold
    ,   em.XLRefundAdvMasterEfin --OK
    ,   em.XLRefundoMasterEfin --OK
	,	em.XLRepublicMasterEfin --OK
    ,   em.XLSBTPGMasterEfin --OK       
    ,   em.XLTPGWMasterEfin --OK         
    ,   em.MSORefundAdvMasterEfin --OK          
    ,   em.MSORefundoMasterEfin --OK
	,	em.MSORepublicMasterEfin --OK
    ,   em.MSOSBTPGMasterEfin --OK      
    ,   em.MSOTPGWMasterEfin --OK        
	from
        @efin e 
		
		left join (
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
			,   row_number() over ( partition by ba1.EfinID, ba1.BankID order by ba1.BankAppID desc) AS 'RowNumber'    
			from        
				@bapps ba1 
			where
				ba1.Deleted = 0 and ba1.BankID = 'S'
		) sbtpgapp  on e.EfinID = sbtpgapp .EfinID
            and sbtpgapp.RowNumber = 1

		left join (
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
			,   row_number() over ( partition by ba1.EfinID, ba1.BankID order by ba1.BankAppID desc) AS 'RowNumber'    
			from        
				@bapps ba1 
			where
				ba1.Deleted = 0 and ba1.BankID = 'W'
		) worldapp on e.EfinID = worldapp.EfinID
            and worldapp.RowNumber = 1

		left join (
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
			,   row_number() over ( partition by ba1.EfinID, ba1.BankID order by ba1.BankAppID desc) AS 'RowNumber'    
			from        
				@bapps ba1 
			where
				ba1.Deleted = 0 and ba1.BankID = 'R'
		) republicapp on e.EfinID = republicapp.EfinID
            and republicapp.RowNumber = 1

		left join (
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
			,   row_number() over ( partition by ba1.EfinID, ba1.BankID order by ba1.BankAppID desc) AS 'RowNumber'    
			from        
				@bapps ba1 
			where
				ba1.Deleted = 0 and ba1.BankID = 'V'
		) raapp on e.EfinID = raapp.EfinID
            and raapp.RowNumber = 1

		left join (
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
			,   row_number() over ( partition by ba1.EfinID, ba1.BankID order by ba1.BankAppID desc) AS 'RowNumber'    
			from        
				@bapps ba1 
			where
				ba1.Deleted = 0 and ba1.BankID = 'F'
		) refundoapp on e.EfinID = refundoapp.EfinID
            and refundoapp.RowNumber = 1
		
		left join (
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
			,   row_number() over ( partition by ba1.EfinID order by ba1.BankAppID desc) AS 'RowNumber'    
			from        
				@bapps ba1 
			where
				ba1.Deleted = 0
		) ba on e.EfinID = ba.EfinID
            and ba.RowNumber = 1

        --left join (
        --        select
        --            er1.BankCode
        --        ,   er1.BankAppID
        --        ,   MAX(er1.rowID) RegrRowID
        --        from
        --            --dbo.efin_regr er1
        --            @bapps ba2 join dbo.efin_regr er1 on ba2.BankId = er1.BankCode
        --                and ba2.BankAppID = er1.BankAppID
        --        group by
        --            er1.BankCode
        --        ,   er1.BankAppID) lr ON ba.BankID = lr.BankCode
        --    and ba.BankAppID = lr.BankAppID
        --left join dbo.efin_regr er ON lr.RegrRowID = er.rowID 
        --left join dbo.ltblBankRegRejects br ON er.EfinError = br.RejectCode 
        --    and er.BankCode = br.Bank 
        --left join dbo.ltblBankRegistrationStatus brs on brs.BankID = er.BankCode 
        --    and brs.EFINStatus = er.EfinStatus 
        --left join dbo.ltblRegistrationStatusDescription rsd on rsd.Registered = case 
        --                                                                            when brs.Registered is not null then brs.Registered 
        --                                                                            else case 
        --                                                                                    when ba.Delivered = 1 then 'P' 
        --                                                                                    --else 'U' 
        --                                                                                 end
        --                                                                        end 

        left join (
                select
                    sbtpger1.BankCode
                ,   sbtpger1.BankAppID
                ,   MAX(sbtpger1.rowID) RegrRowID
                from
                    @bapps sbtpgba2 join dbo.efin_regr sbtpger1 on sbtpgba2.BankId = 'S'
                        and sbtpgba2.BankAppID = sbtpger1.BankAppID
                group by
                    sbtpger1.BankCode
                ,   sbtpger1.BankAppID) sbtpglr ON sbtpgapp.BankID = sbtpglr.BankCode
            and sbtpgapp.BankAppID = sbtpglr.BankAppID
        left join dbo.efin_regr sbtpger ON sbtpglr.RegrRowID = sbtpger.rowID 
        left join dbo.ltblBankRegRejects sbtpgbr ON sbtpger.EfinError = sbtpgbr.RejectCode 
            and sbtpger.BankCode = sbtpgbr.Bank 
        left join dbo.ltblBankRegistrationStatus sbtpgbrs on sbtpgbrs.BankID = sbtpger.BankCode 
            and sbtpgbrs.EFINStatus = sbtpger.EfinStatus 
        left join dbo.ltblRegistrationStatusDescription sbtpgrsd on sbtpgrsd.Registered = case 
                                                                                    when sbtpgbrs.Registered is not null then sbtpgbrs.Registered 
                                                                                    else case 
                                                                                            when sbtpgapp.Delivered = 1 then 'P' 
																		                    else case when sbtpgapp.bankappID is not null then 'U' end
                                                                                         end
                                                                                end 

        left join (
                select
                    worlder1.BankCode
                ,   worlder1.BankAppID
                ,   MAX(worlder1.rowID) RegrRowID
                from
                    @bapps worldba2 join dbo.efin_regr worlder1 on worldba2.BankId = 'W'
                        and worldba2.BankAppID = worlder1.BankAppID
                group by
                    worlder1.BankCode
                ,   worlder1.BankAppID) worldlr ON worldapp.BankID = worldlr.BankCode
            and worldapp.BankAppID = worldlr.BankAppID
        left join dbo.efin_regr worlder ON worldlr.RegrRowID = worlder.rowID 
        left join dbo.ltblBankRegRejects worldbr ON worlder.EfinError = worldbr.RejectCode 
            and worlder.BankCode = worldbr.Bank 
        left join dbo.ltblBankRegistrationStatus worldbrs on worldbrs.BankID = worlder.BankCode 
            and worldbrs.EFINStatus = worlder.EfinStatus 
        left join dbo.ltblRegistrationStatusDescription worldrsd on worldrsd.Registered = case 
                                                                                    when worldbrs.Registered is not null then worldbrs.Registered 
                                                                                    else case 
                                                                                            when worldapp.Delivered = 1 then 'P' 
																		                    else case when worldapp.bankappID is not null then 'U' end
                                                                                         end
                                                                                end 
		
		left join (
                select
                    raer1.BankCode
                ,   raer1.BankAppID
                ,   MAX(raer1.rowID) RegrRowID
                from
                    @bapps raba2 join dbo.efin_regr raer1 on raba2.BankId = 'V'
                        and raba2.BankAppID = raer1.BankAppID
                group by
                    raer1.BankCode
                ,   raer1.BankAppID) ralr ON raapp.BankID = ralr.BankCode
            and raapp.BankAppID = ralr.BankAppID
        left join dbo.efin_regr raer ON ralr.RegrRowID = raer.rowID 
        left join dbo.ltblBankRegRejects rabr ON raer.EfinError = rabr.RejectCode 
            and raer.BankCode = rabr.Bank 
        left join dbo.ltblBankRegistrationStatus rabrs on rabrs.BankID = raer.BankCode 
            and rabrs.EFINStatus = raer.EfinStatus 
        left join dbo.ltblRegistrationStatusDescription rarsd on rarsd.Registered = case 
                                                                                    when rabrs.Registered is not null then rabrs.Registered 
                                                                                    else case 
                                                                                            when raapp.Delivered = 1 then 'P' 
																		                    else case when raapp.bankappID is not null then 'U' end
                                                                                         end
                                                                                end 

        left join (
                select
                    republicer1.BankCode
                ,   republicer1.BankAppID
                ,   MAX(republicer1.rowID) RegrRowID
                from
                    @bapps republicba2 join dbo.efin_regr republicer1 on republicba2.BankId = 'R'
                        and republicba2.BankAppID = republicer1.BankAppID
                group by
                    republicer1.BankCode
                ,   republicer1.BankAppID) republiclr ON republicapp.BankID = republiclr.BankCode
            and republicapp.BankAppID = republiclr.BankAppID
        left join dbo.efin_regr republicer ON republiclr.RegrRowID = republicer.rowID 
        left join dbo.ltblBankRegRejects republicbr ON republicer.EfinError = republicbr.RejectCode 
            and republicer.BankCode = republicbr.Bank 
        left join dbo.ltblBankRegistrationStatus republicbrs on republicbrs.BankID = republicer.BankCode 
            and republicbrs.EFINStatus = republicer.EfinStatus 
        left join dbo.ltblRegistrationStatusDescription republicrsd on republicrsd.Registered = case 
                                                                                    when republicbrs.Registered is not null then republicbrs.Registered 
                                                                                    else case 
                                                                                            when republicapp.Delivered = 1 then 'P' 
																		                    else case when republicapp.bankappID is not null then 'U' end
                                                                                         end
                                                                                end 

        left join (
                select
                    refundoer1.BankCode
                ,   refundoer1.BankAppID
                ,   MAX(refundoer1.rowID) RegrRowID
                from
                    @bapps refundoba2 join dbo.efin_regr refundoer1 on refundoba2.BankId = 'F'
                        and refundoba2.BankAppID = refundoer1.BankAppID
                group by
                    refundoer1.BankCode
                ,   refundoer1.BankAppID) refundolr ON refundoapp.BankID = refundolr.BankCode
            and refundoapp.BankAppID = refundolr.BankAppID
        left join dbo.efin_regr refundoer ON refundolr.RegrRowID = refundoer.rowID 
        left join dbo.ltblBankRegRejects refundobr ON refundoer.EfinError = refundobr.RejectCode 
            and refundoer.BankCode = refundobr.Bank 
        left join dbo.ltblBankRegistrationStatus refundobrs on refundobrs.BankID = refundoer.BankCode 
            and refundobrs.EFINStatus = refundoer.EfinStatus 
        left join dbo.ltblRegistrationStatusDescription refundorsd on refundorsd.Registered = case 
                                                                                    when refundobrs.Registered is not null then refundobrs.Registered 
                                                                                    else case 
                                                                                            when refundoapp.Delivered = 1 then 'P' 
																		                    else case when refundoapp.bankappID is not null then 'U' end
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

        left join (
                    -- Find if any bank apps are delivered for this EFIN
                    select
                        ba2.EfinID   
                    ,   max(isnull(convert(tinyint,ba2.delivered),0)) AnyDeliveredApp
                    from
                        @bapps ba2
                    where
                        ba2.Deleted = 0 and ba2.BankID = 'S'
                    group by
                        ba2.EfinID
        ) tpgada on e.efinId = tpgada.EfinID

		        left join (
                    -- Find if any bank apps are delivered for this EFIN
                    select
                        ba2.EfinID   
                    ,   max(isnull(convert(tinyint,ba2.delivered),0)) AnyDeliveredApp
                    from
                        @bapps ba2
                    where
                        ba2.Deleted = 0 and ba2.BankID = 'W'
                    group by
                        ba2.EfinID
        ) worldada on e.efinId = worldada.EfinID

		left join (
                    -- Find if any bank apps are delivered for this EFIN
                    select
                        ba2.EfinID   
                    ,   max(isnull(convert(tinyint,ba2.delivered),0)) AnyDeliveredApp
                    from
                        @bapps ba2
                    where
                        ba2.Deleted = 0 and ba2.BankID = 'V'
                    group by
                        ba2.EfinID
        ) raada on e.efinId = raada.EfinID

		left join (
                    -- Find if any bank apps are delivered for this EFIN
                    select
                        ba2.EfinID   
                    ,   max(isnull(convert(tinyint,ba2.delivered),0)) AnyDeliveredApp
                    from
                        @bapps ba2
                    where
                        ba2.Deleted = 0 and ba2.BankID = 'R'
                    group by
                        ba2.EfinID
        ) republicada on e.efinId = republicada.EfinID

		left join (
                    -- Find if any bank apps are delivered for this EFIN
                    select
                        ba2.EfinID   
                    ,   max(isnull(convert(tinyint,ba2.delivered),0)) AnyDeliveredApp
                    from
                        @bapps ba2
                    where
                        ba2.Deleted = 0 and ba2.BankID = 'F'
                    group by
                        ba2.EfinID
        ) refundoada on e.efinId = refundoada.EfinID

        left join @efinMaster em on em.account = @account
order by
    e.efin
,   ba.BankAppID