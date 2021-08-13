
-- =============================================
-- Author:		Charles Krebs
-- Create date: 7/12/2013
-- Description:	Rebuild the tblDailyFilingActivity and tblYearlyFilingActivity 
--              records for this season.
-- Updated 1/7/2014 Charles Krebs - Cast ldate to Date -- Removed Yearly Calculations
-- =============================================
CREATE PROCEDURE [dbo].[ke_rebuildDailyFilingActivity]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Season int = dbo.getXlinkSeason()
    declare @yearlyUpdateCutoff date = '05/31/' + convert(char(4),@Season)
    declare @cdate date = getdate()



	CREATE TABLE #TempDailyActivity
	(Account varchar(8) not null,
	 UserID int not null,
	 EFIN int not null,
	 Date date not null,
	 Efiles int not null default 0,
	 StateEfiles int not null default 0,
	 Acks int not null default 0,
	 Rejects int not null default 0,
	 StateAcks int not null default 0,
	 StateRejects int not null default 0,
     SubmittedBankProducts int not null default 0,
	 FundedBankProducts int not null default 0,
     SubmittedProtectionPlusBankProducts int not null default 0,
	 FundedProtectionPlusBankProducts int not null default 0, 
     SubmittedCADRProducts int not null default 0,
	 FundedCADRProducts int not null default 0, 
	 Constraint PK_TempDA Primary Key CLUSTERED (Account, UserID, EFIN, Date))

	INSERT INTO #TempDailyActivity
	(Account, UserID, EFIN, Date, Efiles)
		
	SELECT tblUser.account, tblTaxmast.user_id UserID, tblTaxmast.efin, 
	cast(ldate as date) FileDate, COUNT(*) Efiles
	FROM tblTaxMast
	LEFT JOIN efin ON efin.efin = tblTaxmast.efin
	LEFT JOIN dbCrossLink..tblUser ON tblUser.user_id = tblTaxmast.user_id
	WHERE ldate is not null
	GROUP BY tblUser.account, tblTaxmast.user_id, tblTaxmast.EFIN, cast(ldate as DATE)

	
    select
        u.account
    ,   u.[user_id] UserID
    ,   tm.efin
    ,   tm.irs_ack_dt ResponseDate
    ,   sum(case when tm.irs_acc_cd = 'A' then 1 else 0 end) Acks
    ,   sum(case when tm.irs_acc_cd = 'R' then 1 else 0 end) Rejects
    ,   sum(case when tm.isBankProd = 1 and tm.irs_acc_cd = 'A' then 1 else 0 end) SubmittedBankProducts
    ,   sum(case when tm.isBankProd = 1 and tm.irs_acc_cd = 'A' and tmf.AUD = 1 then 1 else 0 end) SubmittedProtectionPlusBankProducts
    ,   sum(case when tm.isBankProd = 1 and tm.irs_acc_cd = 'A' and tmf.CAD = 1 then 1 else 0 end) SubmittedCADRProducts
    into 
        #Responses
    from
        dbo.tblTaxmast tm left join dbo.efin e on tm.efin = e.Efin
        left join dbCrosslinkGlobal.dbo.tblUser u on tm.[user_id] = u.[user_id]
        left join(
                    select
                        tmf1.pssn
                    ,   max(case when tmf1.tag = 'AUD' then 1 else 0 end) AUD
                    ,   max(case when tmf1.tag = 'CAD' then 1 else 0 end) CAD
                    from    
                        dbo.tblTaxmastFee tmf1
                    where
                        tmf1.tag in('AUD','CAD')
                        and tmf1.feeType = 1
                    group by
                        tmf1.pssn
                 ) tmf on tm.pssn = tmf.pssn
    where
        tm.irs_ack_dt is not null
    group by
        u.account 
    ,   u.[user_id] 
    ,   tm.efin
    ,   tm.irs_ack_dt 


	-- Update Responses of existing records
	UPDATE DFA
	SET Acks = #Responses.Acks
    , Rejects = #Responses.Rejects
    , SubmittedBankProducts = #Responses.SubmittedBankProducts
    , SubmittedProtectionPlusBankProducts = #Responses.SubmittedProtectionPlusBankProducts  
    , SubmittedCADRProducts = #Responses.SubmittedCADRProducts
	FROM #TempDailyActivity DFA
		INNER JOIN #Responses ON #Responses.Account = DFA.Account
			AND #Responses.UserID = DFA.UserID
			AND #Responses.efin = DFA.EFIN
			AND #Responses.ResponseDate = DFA.Date

	-- Delete temporary responses of existing records
	DELETE #Responses
	FROM #TempDailyActivity DFA
		INNER JOIN #Responses ON #Responses.Account = DFA.Account
			AND #Responses.UserID = DFA.UserID
			AND #Responses.efin = DFA.EFIN
			AND #Responses.ResponseDate = DFA.Date

	-- Insert Responses of non-existing records
	INSERT INTO #TempDailyActivity
	(Account, UserID, EFIN, Date, Acks, Rejects, SubmittedBankProducts,SubmittedProtectionPlusBankProducts,SubmittedCADRProducts)
	
	SELECT Account, UserID, EFIN, ResponseDate, Acks, Rejects,SubmittedBankProducts,SubmittedProtectionPlusBankProducts,SubmittedCADRProducts
	FROM #Responses

	DROP Table #Responses

	SELECT 
        u.account
    ,   tm.[user_id] UserID
    ,   tm.efin
    ,   tm.fullyFundedDate FundedDate
    --,   Cast(CAST(@Season as varchar(4)) + ltrim(tm.tran_pay_date) as DATE) FundedDate
    ,	COUNT(*) FundedBankProducts
    ,	COUNT(CASE WHEN ap.ffAUD = 1 THEN 1 END) FundedProtectionPlusBankProducts
    ,	COUNT(CASE WHEN ap.ffCAD = 1 THEN 1 END) FundedCADRProducts
	INTO 
        #BankProducts
	FROM 
        dbo.tblTaxMast tm 
	    LEFT JOIN efin e ON e.efin = tm.efin
	    LEFT JOIN dbCrossLink..tblUser u ON u.[user_id] = tm.[user_id]
        left join (
                    select
                        tmf1.pssn
                    ,   max(case when tmf1.tag = 'AUD' and tmf1.reqAmount > 0 and tmf1.payAmount >= tmf1.reqAmount then 1 else 0 end) ffAUD
                    ,   max(case when tmf1.tag = 'CAD' and tmf1.reqAmount > 0 and tmf1.payAmount >= tmf1.reqAmount then 1 else 0 end) ffCAD
                    from    
                        dbo.tblTaxmastFee tmf1
                    where
                        tmf1.tag in('AUD','CAD')
                        and tmf1.feeType = 1
                    group by
                        tmf1.pssn
                  ) ap on tm.pssn = ap.pssn
	WHERE 
        tm.isFullyFunded = 1
        --tm.tran_pay_amt > 0
        --AND tm.tran_pay_amt >= (tm.req_tech_fee + tm.pei_tran_fee + tm.ero_tran_fee + tm.pei_prot_fee)
	GROUP BY 
        u.account
    ,   tm.[User_ID]
    ,   tm.EFIN
    ,   tm.fullyFundedDate

	-- Update Funded Bank Products of existing records
	UPDATE DFA
	SET FundedBankProducts = #BankProducts.FundedBankProducts,
		FundedProtectionPlusBankProducts = #BankProducts.FundedProtectionPlusBankProducts,
        FundedCADRProducts = #BankProducts.FundedCADRProducts
    
	FROM #BankProducts
		INNER JOIN #TempDailyActivity DFA on DFA.Account = #BankProducts.Account
			AND DFA.UserID = #BankProducts.UserID AND DFA.EFIN = #BankProducts.efin
			AND DFA.Date = #BankProducts.FundedDate

	-- Delete temporary bank products of existing records
	DELETE #BankProducts
	FROM #BankProducts
		INNER JOIN #TempDailyActivity DFA on DFA.Account = #BankProducts.Account
			AND DFA.UserID = #BankProducts.UserID AND DFA.EFIN = #BankProducts.efin
			AND DFA.Date = #BankProducts.FundedDate

				
	INSERT INTO #TempDailyActivity
	(Account, UserID, EFIN, Date, FundedBankProducts, FundedProtectionPlusBankProducts,FundedCADRProducts)
	
	SELECT Account, UserID, EFIN, FundedDate, FundedBankProducts, FundedProtectionPlusBankProducts,FundedCADRProducts
	FROM #BankProducts

	DROP TABLE #BankProducts	


	SELECT tblUser.Account, 
		tblStamast.user_id UserID, tblStamast.efin,
	cast(ldate as DATE) FileDate, COUNT(*) Efiles
	INTO #StateEfiles
	FROM tblStamast
		LEFT JOIN efin ON efin.efin = tblStamast.efin
		LEFT JOIN dbCrossLink..tblUser ON tblUser.user_id = tblStamast.user_id
	WHERE ldate is not null
	GROUP BY tblUser.Account, 
		tblStamast.user_id, tblStamast.efin, cast(ldate as DATE)


	-- Update Responses of existing records
	UPDATE DFA
	SET StateEfiles = #StateEfiles.Efiles
	FROM #TempDailyActivity DFA
		INNER JOIN #StateEfiles ON #StateEfiles.Account = DFA.Account
			AND #StateEfiles.UserID = DFA.UserID
			AND #StateEfiles.efin = DFA.EFIN
			AND #StateEfiles.FileDate = DFA.Date

	-- Delete temporary responses of existing records
	DELETE #StateEfiles
	FROM #TempDailyActivity DFA
		INNER JOIN #StateEfiles ON #StateEfiles.Account = DFA.Account
			AND #StateEfiles.UserID = DFA.UserID
			AND #StateEfiles.efin = DFA.EFIN
			AND #StateEfiles.FileDate = DFA.Date


	-- Insert Responses of non-existing records
	INSERT INTO #TempDailyActivity
	(Account, UserID, EFIN, Date, StateEfiles)
	
	SELECT Account, UserID, EFIN, FileDate, Efiles
	FROM #StateEfiles

	DROP Table #StateEfiles

	SELECT tblUser.account, tblStamast.user_id UserID, tblStamast.efin, 
	Cast(rtrim(state_acky) + ltrim(state_ackd) as DATE) ResponseDate, 
	COUNT(CASE WHEN state_ack = 'A' THEN 1 END) Acks,
	COUNT(CASE WHEN state_ack = 'R' THEN 1 END) Rejects
	INTO #StateResponses
	FROM tblStamast
	LEFT JOIN efin ON efin.efin = tblStamast.efin
	LEFT JOIN dbCrossLink..tblUser ON tblUser.user_id = tblStamast.user_id
	WHERE IsNull(state_ackd, '0') > 0
	GROUP BY tblUser.account, tblStamast.User_ID, tblStamast.EFIN, state_ackd, state_acky

	-- Update Responses of existing records
	UPDATE DFA
	SET StateAcks = #StateResponses.Acks, StateRejects = #StateResponses.Rejects
	FROM #TempDailyActivity DFA
		INNER JOIN #StateResponses ON #StateResponses.Account = DFA.Account
			AND #StateResponses.UserID = DFA.UserID
			AND #StateResponses.efin = DFA.EFIN
			AND #StateResponses.ResponseDate = DFA.Date

	-- Delete temporary responses of existing records
	DELETE #StateResponses
	FROM #TempDailyActivity DFA
		INNER JOIN #StateResponses ON #StateResponses.Account = DFA.Account
			AND #StateResponses.UserID = DFA.UserID
			AND #StateResponses.efin = DFA.EFIN
			AND #StateResponses.ResponseDate = DFA.Date

	-- Insert Responses of non-existing records
	INSERT INTO #TempDailyActivity
	(Account, UserID, EFIN, Date, StateAcks, StateRejects)
	
	SELECT Account, UserID, EFIN, ResponseDate, Acks, Rejects
	FROM #StateResponses

	DROP Table #StateResponses


	 

	DELETE FROM dbCrosslinkGlobal.[dbo].[tblDailyFilingActivity]
	WHERE Season = @Season 

	INSERT INTO dbCrosslinkGlobal..tblDailyFilingActivity
	(Account, UserID, EFIN, Season, Date, Efiles, StateEfiles, 
	 Acks, Rejects, StateAcks, StateRejects,SubmittedBankProducts, FundedBankProducts,SubmittedProtectionPlusBankProducts, FundedProtectionPlusBankProducts,SubmittedCADRProducts, FundedCADRProducts, FedBusinessReturns, FedBusinessAcks, StateBusinessReturns, StateBusinessAcks)
 
	 SELECT Account, UserID, EFIN, @Season, DATE, Efiles, StateEfiles, 
	 Acks, Rejects, StateAcks, StateRejects,SubmittedBankProducts, FundedBankProducts,SubmittedProtectionPlusBankProducts, FundedProtectionPlusBankProducts,SubmittedCADRProducts, FundedCADRProducts,0 FedBusinessReturns,0 FedBusinessAcks,0 StateBusinessReturns,0 StateBusinessAcks
	 
	 FROM #TempDailyActivity


/*
    if @cdate <= @yearlyUpdateCutoff
        begin
            delete from 
                dbCrosslinkGlobal.[dbo].[tblYearlyFilingActivity]
            where
                Season = @Season

            insert dbCrosslinkGlobal.[dbo].[tblYearlyFilingActivity](
                Account
            ,   UserID
            ,   EFIN
            ,   Season
            ,   Efiles
            ,   Acks
            ,   Rejects
            ,   FundedBankProducts
            ,   FundedProtectionPlusBankProducts
            ,   FundedCADRProducts
            ,   ActivityEndDate
            )
                select
                    tda.Account
                ,   tda.UserID
                ,   tda.EFIN
                ,   @Season Season
                ,   sum(tda.Efiles) Efiles
                ,   sum(tda.Acks) Acks
                ,   sum(tda.Rejects) Rejects
                ,   sum(tda.FundedBankProducts) FundedBankProducts
                ,   sum(tda.FundedProtectionPlusBankProducts) FundedProtectionPlusBankProducts
                ,   sum(tda.FundedCADRProducts) FundedCADRProducts
                ,   @cdate ActivityEndDate
                from    
                    #TempDailyActivity tda
                group by
                    tda.Account
                ,   tda.UserID
                ,   tda.EFIN
        end
*/

	DROP TABLE #TempDailyActivity

    return


    -- Update the business return counts
    update dfa
        set dfa.FedBusinessReturns = a.FedBusinessReturns
    ,   dfa.FedBusinessAcks =  a.FedBusinessAcks
    ,   dfa.StateBusinessReturns =  a.StateBusinessReturns
    ,   dfa.StateBusinessAcks =  a.StateBusinessAcks
    from
        dbCrosslinkGlobal.dbo.tblDailyFilingActivity dfa join (
                                                                select 
                                                                    u.account
                                                                ,   cm.userid
                                                                ,   cm.efin
                                                                ,   '20' + right(db_name(),2) Season
                                                                ,   convert(date,cm.ldate) ldate
                                                                ,   sum(case when cm.stateid = 'US' then 1 else 0 end) FedBusinessReturns
                                                                ,   sum(case when cm.stateid = 'US' and cm.irs_acc_cd = 'A' then 1 else 0 end) FedBusinessAcks
                                                                ,   sum(case when cm.stateid != 'US' then 1 else 0 end) StateBusinessReturns
                                                                ,   sum(case when cm.stateid != 'US' and cm.irs_acc_cd = 'A' then 1 else 0 end) StateBusinessAcks
                                                                from 
                                                                    dbo.tblCorpmast cm join dbCrosslinkGlobal.dbo.tblUser u on cm.userid = u.[user_id]
                                                                        and cm.ldate is not null
                                                                        and cm.subType in ('EA' COLLATE Latin1_General_CS_AS ,'EB' COLLATE Latin1_General_CS_AS ) 
                                                                group by
                                                                    u.account
                                                                ,   cm.userid
                                                                ,   cm.efin
                                                                ,   cm.ldate
                                                              ) a on dfa.Account = a.account
            and dfa.UserID = a.userid
            and dfa.EFIN = a.efin
            and dfa.Season = a.Season
            and dfa.[Date] = a.ldate
            and (dfa.FedBusinessReturns != a.FedBusinessReturns
                or dfa.FedBusinessAcks !=  a.FedBusinessAcks
                or dfa.StateBusinessReturns !=  a.FedBusinessReturns
                or dfa.StateBusinessAcks !=  a.StateBusinessAcks)


    insert dbCrosslinkGlobal.dbo.tblDailyFilingActivity(Account
    ,   UserID
    ,   EFIN
    ,   Season
    ,   [Date]
    ,   Efiles
    ,   StateEfiles
    ,   Acks
    ,   Rejects
    ,   StateAcks
    ,   StateRejects
    ,   FundedBankProducts
    ,   FundedProtectionPlusBankProducts
    ,   FundedCADRProducts
    ,   SubmittedBankProducts
    ,   SubmittedProtectionPlusBankProducts
    ,   SubmittedCADRProducts
    ,   FedBusinessReturns
    ,   FedBusinessAcks
    ,   StateBusinessReturns
    ,   StateBusinessAcks
    )
        select 
            u.account
        ,   cm.userid
        ,   cm.efin
        ,   '20' + right(db_name(),2) Season
        ,   convert(date,cm.ldate) ldate
        ,   0 Efiles
        ,   0 StateEfiles
        ,   0 Acks
        ,   0 Rejects
        ,   0 StateAcks
        ,   0 StateRejects
        ,   0 FundedBankProducts
        ,   0 FundedProtectionPlusBankProducts
        ,   0 FundedCADRProducts
        ,   0 SubmittedBankProducts
        ,   0 SubmittedProtectionPlusBankProducts
        ,   0 SubmittedCADRProducts
        ,   sum(case when cm.stateid = 'US' then 1 else 0 end) FedBusinessReturns
        ,   sum(case when cm.stateid = 'US' and cm.irs_acc_cd = 'A' then 1 else 0 end) FedBusinessAcks
        ,   sum(case when cm.stateid != 'US' then 1 else 0 end) StateBusinessReturns
        ,   sum(case when cm.stateid != 'US' and cm.irs_acc_cd = 'A' then 1 else 0 end) StateBusinessAcks
        from 
            dbo.tblCorpmast cm join dbCrosslinkGlobal.dbo.tblUser u on cm.userid = u.[user_id]
                and cm.ldate is not null
                and cm.subType in ('EA' COLLATE Latin1_General_CS_AS ,'EB' COLLATE Latin1_General_CS_AS ) 
            left join dbCrosslinkGlobal.dbo.tblDailyFilingActivity dfa on cm.UserID = dfa.userid
                and cm.EFIN = dfa.efin
                and dfa.Season = '20' + right(db_name(),2)
                and convert(date,cm.ldate) = dfa.[Date]
        where 
            dfa.[Date] is null      
        group by
            u.account
        ,   cm.userid
        ,   cm.efin
        ,   convert(date,cm.ldate)


END
