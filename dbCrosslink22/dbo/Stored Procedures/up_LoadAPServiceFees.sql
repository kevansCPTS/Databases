CREATE procedure [dbo].[up_LoadAPServiceFees]
as

declare @maxDate date 
declare @season smallint

declare @apsFees table(
    account         varchar(8)          null
,   [user_id]       int                 null
,   efin            int                 null
,   tran_pay_date   date                null
,   ero_tran_fee    decimal(18,2)       null
,   parentAccount   varchar(8)          null
)


set nocount on

    set @maxDate = case 
                        when datepart(day,getdate()) < 8 then convert(date, dateadd(s,-1,dateadd(mm, datediff(m,0,getdate()),0)))
                        else getdate()
                   end

    set @season =  convert(smallint,'20' + right(DB_NAME(),2))

    insert @apsFees
        select
            a.account
        ,   a.[user_id]
        ,   a.efin
        ,   a.tran_pay_date
        ,   a.ero_tran_fee - isnull(b.chk_adm_fee,0) ero_tran_fee_net -- Added per Chuck R. to remove our check admin fee 2019-02-26
        ,   a.parentAccount
        from
            (
                select 
                    u.account
                ,   tm.[user_id]
                ,   tm.efin
                ,   tm.tran_pay_date
                ,   sum(case 
                        when tm.isFullyFunded = 1 then tm.ero_tran_fee - tm.cpts_admin_fee
                        else tm.tran_pay_amt - tm.pei_tran_fee - tm.req_tech_fee - tm.cpts_admin_fee
                    end / 100.00) ero_tran_fee
                ,   tm.parentAccount
                from
                    [dbo].[tblTaxmast] tm join [dbCrosslinkGlobal].[dbo].[tblUser] u on tm.[user_id] = u.[user_id]
                        and tm.fdate <= @maxDate
                        and tm.tran_pay_amt > tm.pei_tran_fee + tm.req_tech_fee
                group by
                    tm.tran_pay_date
                ,   u.account
                ,   tm.[user_id]
                ,   tm.efin
                ,   tm.parentAccount
            ) a left join (
                            select
                                u.account
                            ,   tm.[user_id]
                            ,   tm.efin
                            ,   tm.tran_pay_date
                            ,   sum(case 
							        when d.chk_date >= tm.irs_ack_dt and (tm.irs_pay_date is not null and tm.sta_pay_date2 is not null and tm.sta_pay_date3 is not null and tm.irs_pay_date is not null) then 4.00
							        when d.chk_date >= tm.irs_ack_dt and (d.chk_date >= tm.sta_pay_date1 or d.chk_date >= tm.sta_pay_date2 or d.chk_date >= tm.sta_pay_date3 or d.chk_date >= tm.irs_pay_date) then 4.00
                                    else 0.00
                                end) chk_adm_fee
                            from   
                                dbo.tbltaxmast tm join dbCrosslinkGlobal.dbo.tblUser u on tm.[user_id] = u.[user_id] 
                                    and tm.fdate <= @maxDate 
                                    and tm.tran_pay_amt > tm.pei_tran_fee + tm.req_tech_fee
                                join dbo.tblDisburse d on tm.pssn = d.pssn
                                    and d.prev_chk_num = 0 
                                    and d.chk_type not in ('A', 'B', 'K', 'W') 
                                    and d.chk_amt != 0
                                join dbo.tbltaxmastfee tmf on tm.pssn = tmf.pssn
                                    and tmf.tag = 'CAF' 
                                    and tmf.feeType = 1
                            group by
                                u.account
                            ,   tm.efin
                            ,   tm.[user_id]
                            ,   tm.tran_pay_date
                          ) b on a.account = b.account
                and a.[user_id] = b.[user_id]
                and a.efin = b.efin
                and a.tran_pay_date = b.tran_pay_date


    delete a
    from
        dbCrosslinkGlobal.dbo.aptxn a join (
                                                select
                                                    apt.RowID
                                                from
                                                    (
                                                        select
                                                            apt1.account
                                                        ,   apt1.efin
                                                        ,   apt1.[user_id]
                                                        ,   apt1.txn_date
                                                        ,   apt1.txn_amt
                                                        ,   apt1.RowID
                                                        ,   apt1.season
                                                        ,   apt1.parentAccount
                                                        from
                                                            dbCrosslinkGlobal.dbo.aptxn apt1
                                                        where
                                                            apt1.txn_type = '1'
                                                            and apt1.txn_stat = 'O'
                                                    ) apt left join @apsFees af on apt.account = af.account
                                                        and apt.efin = af.efin
                                                        and apt.[user_id] = af.[user_id]
                                                        and apt.txn_date = convert(datetime,af.tran_pay_date)
                                                        and isnull(apt.parentAccount,'X') = isnull(af.parentAccount,'X')
                                                        and apt.season = @season
                                                where
                                                    af.tran_pay_date is null    
                                           ) b on a.RowID = b.RowID



    insert dbCrosslinkGlobal.dbo.aptxn(
            [ref_id]
        ,   [txn_type]
        ,   [txn_stat]
        ,   [txn_date]
        ,   [txn_amt]
        ,   [account]
        ,   [user_id]
        ,   [efin]
        ,   [season]
        ,   [parentAccount]
        )
            select 
                0 [ref_id]
            ,   '1' [txn_type]
            ,   'O' [txn_stat]
            ,   af.tran_pay_date
            ,   af.ero_tran_fee
            ,   af.account
            ,   af.[user_id]
            ,   af.efin
            ,   @season
            ,   af.parentAccount
            from
                @apsFees af left join dbCrosslinkGlobal.dbo.aptxn apt on af.account = apt.account
                    and af.[user_id] = apt.[user_id]
                    and af.efin = apt.efin
                    and af.tran_pay_date = apt.txn_date
                    and isnull(af.parentAccount,'X') = isnull(apt.parentAccount,'X')
                    and apt.season = @season
            where
                apt.account is null 

    
    update apt
        set apt.txn_amt = af.ero_tran_fee
    from
        dbCrosslinkGlobal.dbo.aptxn apt join @apsFees af on apt.account = af.account
                    and apt.[user_id] = af.[user_id]
                    and apt.efin = af.efin
                    and apt.txn_date = af.tran_pay_date
                    and isnull(af.parentAccount,'X') = isnull(apt.parentAccount,'X')
                    and apt.season = @season
    where
        apt.txn_amt != af.ero_tran_fee







