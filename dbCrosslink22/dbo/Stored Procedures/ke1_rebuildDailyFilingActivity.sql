
CREATE PROCEDURE [dbo].[ke1_rebuildDailyFilingActivity]
AS
BEGIN

declare @season int = dbo.getXlinkSeason()
declare @yearlyUpdateCutoff date = '05/31/' + convert(char(4),@Season)
declare @cdate date = getdate()

	set nocount on

    create table #TempDailyActivity(
        account                                         varchar(8)      not null
    ,   userId                                          int             not null
    ,   efin                                            int             not null
    ,   aDate                                           date            not null
    ,   eFiles                                          int             not null        default 0
    ,   stateEfiles                                     int             not null        default 0
    ,   acks                                            int             not null        default 0
    ,   rejects                                         int             not null        default 0
    ,   stateAcks                                       int             not null        default 0
    ,   stateRejects                                    int             not null        default 0
    ,   submittedBankProducts                           int             not null        default 0
    ,   fundedBankProducts                              int             not null        default 0
    ,   submittedProtectionPlusBankProducts             int             not null        default 0
    ,   fundedProtectionPlusBankProducts                int             not null        default 0 
    ,   submittedCADRProducts                           int             not null        default 0
    ,   fundedCADRProducts                              int             not null        default 0
    ,   fedBusinessReturns                              int             not null        default 0
    ,   fedBusinessAcks                                 int             not null        default 0
    ,   stateBusinessReturns                            int             not null        default 0
    ,   stateBusinessAcks                               int             not null        default 0
    ,   constraint PK_TempDA primary key clustered(
            Account
        ,   UserID
        ,   EFIN
        ,   aDate
        )
    )

        
    insert #TempDailyActivity(
        account
    ,   userId
    ,   efin
    ,   aDate
    ,   eFiles
    )
        select
            u.account
        ,   tm.[user_id] userId
        ,   tm.efin
        ,   cast(tm.ldate as date) aDate
        ,   count(*) eFiles
        from
            dbo.tblTaxmast tm join dbCrosslinkGlobal.dbo.tblUser u on tm.[user_id] = u.[user_id]
            --left join dbo.efin e on tm.efin = e.efin
        where
            tm.ldate is not null
        group by
            u.account
        ,   tm.[user_id] 
        ,   tm.efin
        ,   cast(tm.ldate as date) 
    


	
    select
        u.account
    ,   u.[user_id] userId
    ,   tm.efin
    ,   tm.irs_ack_dt responseDate
    ,   sum(case when tm.irs_acc_cd = 'A' then 1 else 0 end) acks
    ,   sum(case when tm.irs_acc_cd = 'R' then 1 else 0 end) rejects
    ,   sum(case when tm.isBankProd = 1 and tm.irs_acc_cd = 'A' then 1 else 0 end) submittedBankProducts
    ,   sum(case when tm.isBankProd = 1 and tm.irs_acc_cd = 'A' and tmf.AUD = 1 then 1 else 0 end) submittedProtectionPlusBankProducts
    ,   sum(case when tm.isBankProd = 1 and tm.irs_acc_cd = 'A' and tmf.CAD = 1 then 1 else 0 end) submittedCADRProducts
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
    update tdfa
        set tdfa.acks = r.acks
    ,   tdfa.rejects = r.rejects
    ,   tdfa.submittedBankProducts = r.submittedBankProducts
    ,   tdfa.submittedProtectionPlusBankProducts = r.submittedProtectionPlusBankProducts
    ,   tdfa.submittedCADRProducts = r.submittedCADRProducts 
    from
        #TempDailyActivity tdfa join #Responses r on tdfa.account = r.account
            and tdfa.userId = r.userId
            and tdfa.efin = r.efin
            and tdfa.aDate = r.responseDate


	-- Delete temporary responses of existing records
    delete 
        r   
    from
        #Responses r join #TempDailyActivity tdfa on r.account = tdfa.account
            and r.userId = tdfa.userId
            and r.efin = tdfa.efin
            and r.responseDate = tdfa.aDate


	-- Insert Responses of non-existing records
    insert #TempDailyActivity(
        account
    ,   userId
    ,   efin
    ,   aDate
    ,   acks
    ,   rejects
    ,   submittedBankProducts
    ,   submittedProtectionPlusBankProducts
    ,   submittedCADRProducts
    )
        select 
                r.account
            ,   r.userId
            ,   r.efin
            ,   r.responseDate
            ,   r.acks
            ,   r.rejects
            ,   r.submittedBankProducts
            ,   r.submittedProtectionPlusBankProducts
            ,   r.submittedCADRProducts
        from
            #Responses r

	drop table #Responses



	select 
        u.account
    ,   tm.[user_id] userId
    ,   tm.efin
    ,   tm.fullyFundedDate fundedDate
    ,	count(*) fundedBankProducts
    ,	count(case when ap.ffAUD = 1 then 1 end) fundedProtectionPlusBankProducts
    ,	count(case when ap.ffCAD = 1 then 1 end) fundedCADRProducts
	into 
        #BankProducts
	from 
        dbo.tblTaxMast tm join dbCrossLink.dbo.tblUser u ON tm.[user_id] = u.[user_id]
	    left join efin e on tm.efin = e.efin
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
	where  
        tm.isFullyFunded = 1
	group by
        u.account
    ,   tm.[User_ID]
    ,   tm.EFIN
    ,   tm.fullyFundedDate

	-- Update Funded Bank Products of existing records
    update tdfa
        set tdfa.fundedBankProducts = bp.fundedBankProducts
    ,   tdfa.fundedProtectionPlusBankProducts = bp.fundedProtectionPlusBankProducts
    ,   tdfa.fundedCADRProducts = bp.fundedCADRProducts
    from
        #TempDailyActivity tdfa join #BankProducts bp on tdfa.account = bp.account
            and tdfa.userId = bp.userId
            and tdfa.efin = bp.efin
            and tdfa.aDate = bp.fundedDate


	-- Delete temporary bank products of existing records
    delete
        bp
    from 
        #BankProducts bp join #TempDailyActivity tdfa on bp.account = tdfa.account
            and bp.userId = tdfa.userId
            and bp.efin = tdfa.efin
            and bp.fundedDate = tdfa.aDate
    
    insert #TempDailyActivity(
        account
    ,   userId
    ,   efin
    ,   aDate
    ,   fundedBankProducts
    ,   fundedProtectionPlusBankProducts
    ,   fundedCADRProducts
    )
        select 
                bp.account
            ,   bp.userId
            ,   bp.efin
            ,   bp.fundedDate
            ,   bp.fundedBankProducts
            ,   bp.fundedProtectionPlusBankProducts
            ,   bp.fundedCADRProducts
        from 
            #BankProducts bp


	drop table #BankProducts	




    select
        u.account
    ,   sm.[user_id] userId
    ,   sm.efin
    ,   cast(sm.ldate as date) fileDate
    ,   count(*) eFiles
    into
        #StateEfiles
    from
        dbo.tblStamast sm join dbCrosslinkGlobal.dbo.tblUser u on sm.[user_id] = u.[user_id]
            --left join dbo.efin e on sm.efin = e.efin
    where
        sm.ldate is not null
    group by
        u.account
    ,   sm.[user_id] 
    ,   sm.efin
    ,   cast(sm.ldate as date) 


	-- Update Responses of existing records
    update tdfa 
        set tdfa.stateEfiles = se.eFiles
    from
        #TempDailyActivity tdfa join #StateEfiles se on tdfa.account = se.account
            and tdfa.userId = se.userId
            and tdfa.efin = se.efin
            and tdfa.aDate = se.fileDate    

	-- Delete temporary responses of existing records
    delete
        se
    from
        #StateEfiles se join #TempDailyActivity tdfa on se.account = tdfa.account
            and se.userId = tdfa.userId
            and se.efin = tdfa.efin
            and se.fileDate = tdfa.aDate


	-- Insert Responses of non-existing records
    insert #TempDailyActivity(
        account
    ,   userId
    ,   efin
    ,   aDate
    ,   stateEfiles
    )
        select
                se.account
            ,   se.userId
            ,   se.efin
            ,   se.fileDate
            ,   se.eFiles
        from
            #StateEfiles se


	drop table #StateEfiles



    select
        u.account
    ,   sm.[user_id] userId
    ,   efin
    ,   cast(rtrim(sm.state_acky) + ltrim(sm.state_ackd) as date) responseDate
    ,   count(case when sm.state_ack = 'A' then 1 end) acks
    ,   count(case when sm.state_ack = 'R' then 1 end) rejects
    into 
        #StateResponses
    from
        dbo.tblStamast sm join dbCrosslinkGlobal.dbo.tblUser u on sm.[user_id] = u.[user_id]
            --left join dbo.efin e on sm.efin = e.efin
    where
        isnull(sm.state_ackd,'0') > 0
    group by
        u.account
    ,   sm.[user_id] 
    ,   efin
    ,   cast(rtrim(sm.state_acky) + ltrim(sm.state_ackd) as date) 


	-- Update Responses of existing records
    update tdfa
        set tdfa.stateAcks = sr.acks
    ,   tdfa.stateRejects = sr.rejects
    from
        #TempDailyActivity tdfa join #StateResponses sr on tdfa.account = sr.account
            and tdfa.userId = sr.userId
            and tdfa.efin = sr.efin
            and tdfa.aDate = sr.responseDate


	-- Delete temporary responses of existing records
    delete 
        sr
    from 
        #StateResponses sr join #TempDailyActivity tdfa on sr.account = tdfa.account
            and sr.userId = tdfa.userId
            and sr.efin = tdfa.efin
            and sr.responseDate = tdfa.aDate
    

	-- Insert Responses of non-existing records
    insert #TempDailyActivity(
        account
    ,   userId
    ,   efin
    ,   aDate
    ,   stateAcks
    ,   stateRejects
    )
        select
                sr.account
            ,   sr.userId
            ,   sr.efin
            ,   sr.responseDate
            ,   sr.acks
            ,   sr.rejects
        from
            #StateResponses sr

	drop table #StateResponses






    -- Update the business return counts
    update tdfa
        set tdfa.FedBusinessReturns = a.FedBusinessReturns
    ,   tdfa.FedBusinessAcks =  a.FedBusinessAcks
    ,   tdfa.StateBusinessReturns =  a.StateBusinessReturns
    ,   tdfa.StateBusinessAcks =  a.StateBusinessAcks
    from
        #TempDailyActivity tdfa join (
                                        select 
                                            u.account
                                        ,   cm.userid
                                        ,   cm.efin
                                        --,   '20' + right(db_name(),2) Season
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
                                        ) a on tdfa.Account = a.account
            and tdfa.UserID = a.userid
            and tdfa.EFIN = a.efin
            --and tdfa.Season = a.Season
            and tdfa.aDate = a.ldate
            and (tdfa.FedBusinessReturns != a.FedBusinessReturns
                or tdfa.FedBusinessAcks !=  a.FedBusinessAcks
                or tdfa.StateBusinessReturns !=  a.FedBusinessReturns
                or tdfa.StateBusinessAcks !=  a.StateBusinessAcks)

    -- Add new business return dates 
    insert #TempDailyActivity(Account
    ,   UserID
    ,   EFIN
    ,   aDate
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
            left join #TempDailyActivity tdfa on cm.UserID = tdfa.userid
                and cm.EFIN = tdfa.efin
                --and dfa.Season = '20' + right(db_name(),2)
                and convert(date,cm.ldate) = tdfa.aDate
        where 
            tdfa.aDate is null      
        group by
            u.account
        ,   cm.userid
        ,   cm.efin
        ,   convert(date,cm.ldate)



	-- Delete the data for this season from the daily filing activity table    
    /*
    delete 
        dfa
    from 
        dbCrosslinkGlobal.dbo.tblDailyFilingActivity dfa
    where
        dfa.Season = @season


    insert dbCrosslinkGlobal.dbo.tblDailyFilingActivity(
        Account
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
    ,   SubmittedBankProducts
    ,   FundedBankProducts
    ,   SubmittedProtectionPlusBankProducts
    ,   FundedProtectionPlusBankProducts
    ,   SubmittedCADRProducts
    ,   FundedCADRProducts
    ,   FedBusinessReturns
    ,   FedBusinessAcks
    ,   StateBusinessReturns
    ,   StateBusinessAcks
    )
        select
                tdfa.account
            ,   tdfa.userId
            ,   tdfa.EFIN
            ,   @season Season
            ,   tdfa.aDate
            ,   tdfa.Efiles
            ,   tdfa.StateEfiles
            ,   tdfa.Acks
            ,   tdfa.Rejects
            ,   tdfa.StateAcks
            ,   tdfa.StateRejects
            ,   tdfa.SubmittedBankProducts
            ,   tdfa.FundedBankProducts
            ,   tdfa.SubmittedProtectionPlusBankProducts
            ,   tdfa.FundedProtectionPlusBankProducts
            ,   tdfa.SubmittedCADRProducts
            ,   tdfa.FundedCADRProducts
            ,   0 FedBusinessReturns
            ,   0 FedBusinessAcks
            ,   0 StateBusinessReturns
            ,   0 StateBusinessAcks
        from
            #TempDailyActivity tdfa
    */


    select * from #TempDailyActivity
	drop table #TempDailyActivity


    /*
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
    */

END
