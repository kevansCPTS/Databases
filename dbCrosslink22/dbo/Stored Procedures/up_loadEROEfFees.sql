CREATE procedure [dbo].[up_loadEROEfFees]
as

declare @maxDate date 
declare @season smallint

declare @efFees table(
    account         varchar(8)          null
,   [user_id]       int                 null
,   efin            int                 null
,   tran_pay_date   date                null
,   ero_ef_fee      decimal(18,2)       null
,   parentAccount   varchar(8)          null
)


set nocount on

    set @maxDate = case 
                        when datepart(day,getdate()) < 8 then convert(date, dateadd(s,-1,dateadd(mm, datediff(m,0,getdate()),0)))
                        else getdate()
                   end

    set @season =  convert(smallint,'20' + right(DB_NAME(),2))


    insert @efFees
        select
            a.account
        ,   a.[user_id]
        ,   a.efin
        ,   a.tran_pay_date
        ,   a.ero_ef_fee 
        ,   a.parentAccount
        from
            (
                select 
                    rf.account
                ,   rf.[user_id]
                ,   rf.efin
                ,   rf.tran_pay_date
                ,   sum(rf.paidEROEFFee) ero_ef_fee
                ,   rf.parentAccount
                from
                    dbo.vw_TaxReturnFees rf 
                where
                    rf.fdate <= @maxDate
                    --and rf.ral_flag = '5'
                    and rf.paidEROEFFee > 0
                group by
                    rf.tran_pay_date
                ,   rf.account
                ,   rf.[user_id]
                ,   rf.efin
                ,   rf.parentAccount

                /*
                select 
                    rf.account
                ,   rf.[user_id]
                ,   rf.efin
                ,   rf.tran_pay_date
                ,   sum(rf.paidEROEFFee) ero_ef_fee
                ,   tm.parentAccount
                from
                    dbo.vw_TaxReturnFees rf join dbo.tblTaxmast tm on rf.pssn = tm.pssn
                        and tm.fdate <= @maxDate
                        and tm.ral_flag = '5'
                        and rf.paidEROEFFee > 0
                        and tm.tran_pay_amt > tm.pei_tran_fee + tm.req_tech_fee
                group by
                    rf.tran_pay_date
                ,   rf.account
                ,   rf.[user_id]
                ,   rf.efin
                ,   tm.parentAccount
                */
            ) a 


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
                                                            apt1.txn_type = '9' -- Unused type identified by Chuck.
                                                            and apt1.txn_stat = 'O'
                                                    ) apt left join @efFees ef on apt.account = ef.account
                                                        and apt.efin = ef.efin
                                                        and apt.[user_id] = ef.[user_id]
                                                        and apt.txn_date = convert(datetime,ef.tran_pay_date)
                                                        and isnull(apt.parentAccount,'X') = isnull(ef.parentAccount,'X')
                                                        and apt.season = @season
                                                where
                                                    ef.tran_pay_date is null    
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
            ,   '9' [txn_type]
            ,   'O' [txn_stat]
            ,   ef.tran_pay_date
            ,   ef.ero_ef_fee
            ,   ef.account
            ,   ef.[user_id]
            ,   ef.efin
            ,   @season
            ,   ef.parentAccount
            from
                @efFees ef left join dbCrosslinkGlobal.dbo.aptxn apt on ef.account = apt.account
                    and ef.[user_id] = apt.[user_id]
                    and ef.efin = apt.efin
                    and ef.tran_pay_date = apt.txn_date
                    and isnull(ef.parentAccount,'X') = isnull(apt.parentAccount,'X')
                    and apt.season = @season
                    and apt.txn_type = '9'
            where
                apt.account is null 

   
    update apt
        set apt.txn_amt = ef.ero_ef_fee
    from
        dbCrosslinkGlobal.dbo.aptxn apt join @efFees ef on apt.account = ef.account
                    and apt.txn_type = '9'
                    and apt.[user_id] = ef.[user_id]
                    and apt.efin = ef.efin
                    and apt.txn_date = ef.tran_pay_date
                    and isnull(ef.parentAccount,'X') = isnull(apt.parentAccount,'X')
                    and apt.season = @season
    where
        apt.txn_amt != ef.ero_ef_fee


