create procedure up_rptAuditDefenceELBMIT
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
        e.Company [Company Name]
    ,   tm.efin
    ,   tm.[user_id]
    ,   count(distinct tm.pssn) Total
    ,   sum(case when tm.irs_acc_cd = 'R' then 1 else 0 end) Rejects
    ,   sum(case when tm.irs_acc_cd = 'A' then 1 else 0 end) Acks
    ,   sum(case when tm.irs_acc_cd = ' ' then 1 else 0 end) Pending
    ,   sum(case when tm.ral_flag in(1,2,4) then 1 else 0 end) Non_Financial
    ,   sum(case when tm.ral_flag not in(1,2,4) then 1 else 0 end) Financial

    ,   sum(ad.protPlusFee) totalFeesRequested
    ,   sum(ad.protPlusPayAmt) totalFeesPaid
    ,   sum(ad.protPlusBaseFee) totalBaseFeesRequested
    ,   sum(ad.BaseFeePaid) totalBaseFeesPaid
    ,   sum(isnull(ad.protPlusAddOnFee, 0)) totalAddFeesRequested
    ,   sum(isnull(ad.addOnPaid, 0)) totalAddOnFeesPaid

    from
        tblTaxmast tm join dbCrosslinkGlobal.dbo.tblUser u on tm.[user_id] = u.[user_id]
            and tm.[user_id] > 100 -- not sure why we need this, but it was in the source script from Chuck
        join @aList a on u.account = a.account
        join dbo.efin e on tm.efin = e.efin
        join (
                select 
                    tmf.pssn
                ,   sum(tmf.reqAmount) protPlusFee
                ,   sum(tmf.payAmount) protPlusPayAmt
                ,   max(tmf.payDate) protPlusPayDate
                ,   sum(case when tmf.feeType = 1 then tmf.reqAmount else 0 end) protPlusBaseFee
                ,   sum(case when tmf.feeType = 2 then tmf.reqAmount else 0 end) protPlusAddOnFee
                ,   sum(case when tmf.feeType = 1 then tmf.payAmount else 0 end) BaseFeePaid
                ,   sum(case when tmf.feeType = 2 then tmf.payAmount else 0 end) AddOnPaid
                from
                    @aList a join dbo.tblAccountAncillaryProduct aap on a.account = aap.account
                    join dbo.tblAncillaryProduct ap on aap.aprodId = ap.aprodId
                        and ap.groupId = 2
                    join dbCrosslinkGlobal.dbo.tblUser u on a.account = u.account
                    join dbo.tblTaxmast tm on u.[user_id] = tm.[user_id] 
                    join dbo.tblTaxmastFee tmf on tm.pssn = tmf.pssn
                group by
                    tmf.pssn
             ) ad on tm.pssn = ad.pssn
    group by
        e.Company 
    ,   tm.efin
    ,   tm.[user_id]
    order by
        e.Company 
    ,   tm.efin
    ,   tm.[user_id]
    

    /*
    select 
        a.account
    ,   aap.tag
    from
        @aList a join dbo.tblAccountAncillaryProduct aap on a.account = aap.account
        join dbo.tblAncillaryProduct ap on aap.aprodId = ap.aprodId
            and ap.groupId = 2
        --join dbCrosslinkGlobal.dbo.tblUser u on a.account = u.account
        --join dbo.tblTaxmast tm on u.[user_id] = tm.[user_id] 
        --join dbo.tblTaxmastFee tmf on tm.pssn = tmf.pssn
    order by
        a.account
    ,   aap.tag
    */

