create procedure up_rptReturnsByUserIdELBMIT
as

declare @season smallint

declare @aList table(
    account         varchar(8)
)

    set nocount on 
    
    insert @aList values('ELBMIT')
    set @season = '20' + right(db_name(),2)

    insert @aList
        select 
            ch.childAccount
        from 
            dbCrosslinkGlobal.dbo.tblCustomerHierarchy ch join @aList a on ch.parentAccount = a.account
                and ch.season = @season

    select
        tmt.[user_id]
    ,   tmt.company
    ,   tmt.Total
    ,   tmt.Acks
    ,   tmt.Rejects
    ,   tmt.req_Fees
    ,   tmt.app_Fees
    ,   tmt.fee_pmts
    ,   tmt.Racs
    ,   tmt.Racs_Funded
    ,   tmt.IRS_Payment
    ,   tmt.Acked_Racs
    ,   isnull(smt.stateEFiles,0) stateEFiles
    from
        (
            select
                tm.[user_id] 
            ,   u.company
            ,   count(distinct tm.pssn) Total
            ,   sum(case when tm.irs_acc_cd = 'A' then 1 else 0 end) Acks
            ,   sum(case when tm.irs_acc_cd = 'R' then 1 else 0 end) Rejects
            ,   sum(isnull(tm.tax_prep_fee,0)
                    + isnull(tm.doc_prep_fee,0)
                    + isnull(tm.elf_prep_fee,0)
                    + isnull(tmf.EROAncillaryRequested, 0)
                ) / 100.00 req_Fees
            ,   sum(isnull(tm.tot_prep_fee,0)) / 100.00 app_Fees
            ,   sum(isnull(tm.fee_pay_amt,0)) / 100.00 fee_pmts
            ,   sum(case when tm.ral_flag = 5 then 1 else 0 end) Racs
            ,   sum(case when tm.isFullyFunded = 1 then 1 else 0 end) Racs_Funded
            ,   sum(case when tm.irs_pay_date is not null then 1 else 0 end) IRS_Payment
            ,   sum(case when tm.irs_acc_cd = 'A' and (tm.ral_flag = '5' or (tm.ral_flag = '3' and tm.bank_stat = 'D')) then 1 else 0 end) Acked_Racs
            from
                dbo.tblTaxmast tm join dbCrosslinkGlobal.dbo.tblUser u on tm.[user_id] = u.[user_id]
                    and tm.submissionid != ''
                join @aList a on u.account = a.account
                left join (
                                select 
                                    tmf1.pssn
                                ,   sum(tmf1.reqAmount * 100) EROAncillaryRequested
                                from
                                    @aList a1 join dbCrosslinkGlobal.dbo.tblUser u1 on a1.account = u1.account
                                    join dbo.tblTaxmast tm1 on u1.[user_id] = tm1.[user_id]
                                    join dbo.tblTaxmastFee tmf1 on tm1.pssn = tmf1.pssn
                                        and tmf1.feeType = 2
                                group by
                                    tmf1.pssn    
                          ) tmf on tm.pssn = tmf.pssn
            group by
                tm.[user_id] 
            ,   u.company
        ) tmt left join (
                            select 
                                sm1.[user_id]
                            ,   count(*) stateEFiles
                            from
                                dbo.tblStamast sm1 join dbCrosslinkGlobal.dbo.tblUser u1 on sm1.[user_id] = u1.[user_id]
                                    and (sm1.state_ack = 'A' 
                                        or (sm1.state_id = 'PA' and sm1.state_ack in('C','N')))
                                    and sm1.[user_id] < 997000
                                join @aList a1 on u1.account = a1.account
                            group by
                                sm1.[user_id]
                        ) smt on tmt.[user_id] = smt.[user_id]

    order by
        tmt.[user_id] 
    ,   tmt.company
