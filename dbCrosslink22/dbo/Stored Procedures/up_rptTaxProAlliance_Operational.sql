CREATE procedure [dbo].[up_rptTaxProAlliance_Operational]
as

declare @aList table(
    account         varchar(8)
)

set nocount on 

-- TaxPro Alliance Operational

insert @alist
    values('MAHJOS')

insert @alist
    select
        ch.childAccount
    from
        dbCrosslinkGlobal.dbo.tblCustomerHierarchy ch join @aList a on ch.parentAccount = a.account
            and ch.season = 2017
        left join @aList al1 on ch.childAccount = al1.account
    where
        al1.account is null 

select
    b.account
,   b.[user_id]
,   b.EFIN
,   b.totalReturns
,   b.efileVolume
,   b.ackCount
,   b.requestedBP
,   b.fundedBP
,   b.requestedProtPlus requestedAuditAllies
,   b.fundedProtPlus fundedAuditAllies
,   isnull(sm.requestedStateRT,0) requestedStateRT
,   b.fundedStateRTs
,   ISNULL(sm.stateAcks,0) stateAcks
from
    (

        select    
            u.account
        ,   u.[user_id]
        ,   isnull(tm.efin, rm.EFIN) EFIN
        ,   COUNT(rm.primaryssn) totalReturns 
        ,   COUNT(tm.pssn) efileVolume
        ,   SUM(case tm.irs_acc_cd when 'A' then 1 else 0 end) ackCount
        ,   SUM(case when tm.irs_acc_cd = 'A' and isnull(tm.isBankProd, 0) = 1 then 1 else 0 end) requestedBP
        ,   SUM(case tm.isFullyFunded when 1 then 1 else 0 end) fundedBP
        ,   SUM(case when tm.irs_acc_cd = 'A' and tf.audit_req = 1 then 1 else 0 end) requestedProtPlus
        ,   SUM(case when tm.irs_acc_cd = 'A' and tf.audit_fund= 1 then 1 else 0 end) fundedProtPlus
        ,   sum(case when ISNULL(tm.sta_pay_amt3, 0) <> 0 then 3 when ISNULL(tm.sta_pay_amt2, 0) <> 0 then 2 when ISNULL(tm.sta_pay_amt1, 0) <> 0 then 1 else 0 end) fundedStateRTs

        from 
            @aList a join dbcrosslinkglobal.dbo.tblUser u on a.account = u.account
                and u.[user_id] < 996000
            join dbcrosslink17.dbo.tblReturnMaster rm on rm.UserID = u.[user_id]
            left join dbcrosslink17.dbo.tblTaxmast tm on tm.[user_id] = rm.userid 
                and tm.pssn = rm.PrimarySSN 
                and tm.filing_stat = rm.FilingStatus 
            left join (
                        select
                            tf1.pssn
                        ,   case when tf1.tag = 'AD3' then 1 else 0 end audit_req
                        ,   case when tf1.tag = 'AD3' and tf1.payAmount >= tf1.reqAmount then 1 else 0 end audit_fund
                        from
                            dbo.tblTaxmastFee tf1
                        where
                            tf1.tag in ('AD3')                
                  ) tf on tm.pssn = tf.pssn
        group by 
            u.account
        ,   u.[user_Id]
        ,   isnull(tm.efin, rm.EFIN)
        union select
            u.account
        ,   u.[user_id]
        ,   isnull(tm.efin, e.EFIN) EFIN
        ,   COUNT(rm.primaryssn) totalReturns 
        ,   COUNT(tm.pssn) efileVolume
        ,   SUM(case tm.irs_acc_cd when 'A' then 1 else 0 end) ackCount
        ,   SUM(case when tm.irs_acc_cd = 'A' and isnull(tm.isBankProd, 0) = 1 then 1 else 0 end) requestedBP
        ,   SUM(case tm.isFullyFunded when 1 then 1 else 0 end) fundedBP
        ,   SUM(case when tm.irs_acc_cd = 'A' and tf.protPlus_req = 1 then 1 else 0 end) requestedProtPlus
        ,   SUM(case when tm.irs_acc_cd = 'A' and tf.protPlus_fund = 1 then 1 else 0 end) fundedProtPlus
        ,   sum(case when ISNULL(tm.sta_pay_amt3, 0) <> 0 then 3 when ISNULL(tm.sta_pay_amt2, 0) <> 0 then 2 when ISNULL(tm.sta_pay_amt1, 0) <> 0 then 1 else 0 end) fundedStateRTs
        from
            @aList a join dbcrosslinkglobal.dbo.tblUser u on a.account = u.account
                and u.[user_id] > 996000
            join Taxbrain17.dbo.tblSvcBureau sb on u.[user_id] = sb.SvcB_UserID
            join Taxbrain17.dbo.tblEFIN e on e.SvcB_ID = sb.SvcB_ID
            join Taxbrain17.dbo.tblVTaxLogin vl on e.EFIN_ID = vl.TypeID
                and vl.LoginType like 'E%'
            join Taxbrain17.dbo.tblReturn r on vl.LoginID = r.LoginID
                and r.ReturnDeleted is null
            left join dbcrosslink17.dbo.tbltaxmast tm on r.returnid = tm.rtn_id 
            left join dbcrosslink17.dbo.tblReturnMaster rm on tm.[user_id] = rm.UserID
                and tm.filing_stat = rm.FilingStatus
                and tm.pssn = rm.PrimarySSN

            left join (
                        select
                            tf1.pssn
                        ,   case when tf1.tag = 'AD3' then 1 else 0 end protPlus_req
                        ,   case when tf1.tag = 'AD3' and tf1.payAmount >= tf1.reqAmount then 1 else 0 end protPlus_fund
                        from
                            dbo.tblTaxmastFee tf1
                        where
                            tf1.tag in ('AD3')                
                    ) tf on tm.pssn = tf.pssn
        group by 
            u.account
        ,   u.[user_id]
        ,   isnull(tm.EFIN, e.EFIN)
    ) b left join (
                        select  
                            u1.account
                        ,   u1.[User_Id]
                        ,   sm1.efin
                        ,   sum(case when sm1.state_ralf = 3 then 1 else 0 end) requestedStateRT
                        ,   sum(case when sm1.state_ack = 'A' then 1 else 0 end) stateAcks
                        from
                            @alist a1 join dbcrosslinkglobal.dbo.tblUser u1 on a1.account = u1.account
                               and u1.[user_id] < 996000
                            join dbcrosslink17.dbo.tblStamast sm1 on u1.[user_id] = sm1.[user_id]
                        group by 
                            u1.account
                        ,   u1.[user_id]
                        ,   sm1.EFIN 
                   ) sm on b.account = sm.account
        and b.[user_id] = sm.[user_id] 
        and b.efin = sm.EFIN
order by
    b.account
,   b.[user_id]
,   b.EFIN
