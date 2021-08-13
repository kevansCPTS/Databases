

-- =============================================
-- Author:		Charles Krebs & Tim Gong
-- Create date: 9/14/2010
-- Description:	Rebuild the EFIN stats table for the current season.
-- 9/16/2011 Modified to add prot plus
-- 1/31/2013 Removed all references to rals and roll -Charles Krebs
-- 12/19/2013 Updated to use the computed columns for prot plus and fully funded -KJE
-- 08/29/2019 Added two new fields - tot_acks_amt and tot_funded_amt
-- =============================================
CREATE PROCEDURE [dbo].[spRebuildEFINStats] 
AS
BEGIN

	DECLARE @season int

	SET @season = dbo.getXlinkSeason()

	DELETE FROM dbCrosslinkGlobal..efin_stats 
	WHERE season = @season
	AND ISNULL(ManualEntry, 0) = 0



    insert dbCrosslinkGlobal.dbo.efin_stats(
        efin
    ,   season
    ,   bank_id
    ,   tot_ral_cnt
    ,   unpaid_cnt
    ,   booked_amt
    ,   paid_amt
    ,   unpaid_amt
    ,   loss_percent
    ,   tot_rac_cnt
    ,   efiles
    ,   tran_fee_pd_cnt
    ,   rals_funded
    ,   racs_funded
    ,   [user_ID]
    ,   account
    ,   rejects
    ,   total_returns
    ,   TransmitDate
    ,   prot_plus_acks
    ,   prot_plus_funded
    ,   prot_plus_apps

    ,   tot_loan_advanced
    ,   tot_loan_outstanding
    ,   tot_RT_received
    ,   tot_RT_acknowledged   
    ,   tot_unique_efiles
    ,   tot_acks
    ,   ultimate_reject_rate
    ,   loss_rate   
    ,   rt_funding_rate
    ,   tot_acks_amt
    ,   tot_funded_amt
    )
        select
            a.efin
        ,   @season season
        ,   a.bank_id
        ,   0
        ,   0
        ,   0
        ,   0
        ,   0
        ,   0 loan_loss
        ,   isnull(a.tot_rac_cnt,0) tot_rac_cnt
        ,   isnull(a.efiles,0) efiles 
        ,   isnull(a.racs_funded,0) racs_funded 
        ,   0
        ,   isnull(a.racs_funded,0) racs_funded
        ,   a.[user_id]
        ,   u.account
        ,   isnull(a.rejects,0) rejects 
        ,   isnull(a.total_returns,0) total_returns
        ,   a.TransmitDate     
        ,   isnull(a.prot_plus_acks,0) prot_plus_acks
        ,   isnull(a.protracs_funded,0) protracs_funded
        ,   isnull(a.prot_plus_racs,0) prot_plus_racs


        ,   isnull(a.tot_loan_advanced,0) tot_loan_advanced
        ,   isnull(a.tot_loan_outstanding,0) tot_loan_outstanding

        ,   isnull(a.tot_RT_received,0) tot_RT_received
        ,   isnull(a.tot_RT_acknowledged,0) tot_RT_acknowledged

        ,   isnull(a.tot_unique_efiles,0) tot_unique_efiles
        ,   isnull(a.tot_acks,0) tot_acks

        --,   case when isnull(a.tot_acks,0) = 0 then 0 else (isnull(a.tot_unique_efiles,0) - isnull(a.tot_acks,0)) / isnull(a.tot_acks,0) * 100.0 end ultimate_reject_rate
        --,   case when isnull(a.tot_loan_advanced,0) = 0 then 0 else (isnull(a.tot_loan_outstanding,0) / isnull(a.tot_loan_advanced,0)) * 100.0 end loss_rate
        --,   case when isnull(a.tot_RT_acknowledged,0) = 0 then 0 else (isnull(a.tot_RT_received,0) / isnull(a.tot_RT_acknowledged,0)) * 100.0 end rt_funding_rate

        ,   convert(decimal(16,2),case when isnull(a.tot_acks,0) = 0 and isnull(a.tot_unique_efiles,0) != 0 then 100.0 when isnull(a.tot_acks,0) = 0 then 0 else ((isnull(a.tot_unique_efiles,0) - isnull(a.tot_acks,0)) * 1.0) / isnull(a.tot_acks,0) * 100.0 end) ultimate_reject_rate
        ,   convert(decimal(16,2),case when isnull(a.tot_loan_advanced,0) = 0 then 0 else ((isnull(a.tot_loan_outstanding,0) * 1.00) / (isnull(a.tot_loan_advanced,0)) * 1.00) * 100.0 end) loss_rate
        ,   convert(decimal(16,2),case when isnull(a.tot_RT_acknowledged,0) = 0 then 0 else (isnull(a.tot_RT_received,0) / isnull(a.tot_RT_acknowledged,0)) * 100.0 end) rt_funding_rate

        ,   isnull(a.tot_acks_amt,0) tot_acks_amt
        ,   isnull(a.tot_funded_amt,0) tot_funded_amt
        from
            (
                select
                    tm1.efin
                ,   tm1.bank_id
                ,   sum(case when tm1.irs_acc_cd = 'A' and tm1.isBankProd = 1 then 1 else 0 end) tot_rac_cnt
                ,   sum(case when tm1.irs_acc_cd = 'A' then 1 else 0 end) efiles  
                ,   sum(case when tm1.irs_acc_cd = 'A' and tm1.isBankProdFunded = 1 then 1 else 0 end) racs_funded
                ,   tm1.[user_id]
                ,   sum(case when tm1.irs_acc_cd = 'R' then 1 else 0 end) rejects 
                ,   count(*) total_returns
                ,   tm1.xmit_date TransmitDate     
                ,   sum(case when tm1.irs_acc_cd = 'A' and tm1.isProtPlus = 1 then 1 else 0 end) prot_plus_acks
                ,   sum(case when tm1.irs_acc_cd = 'A' and tm1.isBankProd = 1 and tm1.isProtPlusFunded = 1 then 1 else 0 end) protracs_funded
                ,   sum(case when tm1.irs_acc_cd = 'A' and tm1.isBankProd = 1 and tm1.isProtPlus = 1 then 1 else 0 end) prot_plus_racs

                ,   sum(case when tm1.ral_flag = '5' and tm1.req_loan_amt > 0 and tm1.bank_stat = 'A' then tm1.req_loan_amt else 0 end)  tot_loan_advanced
                ,   sum(case when tm1.ral_flag = '5' and tm1.req_loan_amt > 0 and tm1.irs_pay_amt = 0 and tm1.bank_stat = 'A' then tm1.req_loan_amt else 0 end)  tot_loan_outstanding

                ,   sum(case when tm1.ral_flag = '5' and tm1.irs_pay_amt > 0 and tm1.bank_stat = 'A' then tm1.irs_pay_amt / 100.00 else 0 end)  tot_RT_received
                ,   sum(case when tm1.ral_flag = '5' and tm1.refund > 0 and tm1.bank_stat != ' ' then tm1.refund else 0 end)  tot_RT_acknowledged

                ,   sum(case when tm1.irs_acc_cd != ' ' then 1 else 0 end) tot_unique_efiles
                ,   sum(case when tm1.irs_acc_cd = 'A' then 1 else 0 end) tot_acks  

                ,   sum(case when tm1.irs_acc_cd = 'A' then tm1.refund else 0 end) tot_acks_amt  
                ,   sum(case when tm1.irs_acc_cd = 'A' and tm1.isBankProdFunded = 1 then irs_pay_amt / 100.00 else 0 end) tot_funded_amt  
                from
                    dbo.tblTaxmast tm1
                group by
                    tm1.efin
                ,   tm1.bank_id
                ,   tm1.[user_id]
                ,   tm1.xmit_date   
            ) a left join dbCrosslinkGlobal.dbo.tblUser u on a.[user_id] = u.[user_id]





/*
        select 
            a.efin 
        ,   a.season 
        ,   a.bank_id
        ,   0
        ,   0
        ,   0
        ,   0
        ,   0
        ,   0 loan_loss
        ,   IsNull(tot_rac_cnt, 0)
        ,   IsNull(efiles, 0)
        ,   IsNull(racs_funded, 0)
        ,   0 
        ,   IsNull(racs_funded, 0)
        ,   a.user_ID
        ,   account
        ,   IsNull(rejects, 0)
        ,   IsNull(total_returns, 0)
        ,   a.TransmitDate
        ,   IsNull(prot_plus_acks, 0)
        ,   IsNull(a.protracs_funded, 0)
        ,   ISNULL(a.prot_plus_racs, 0)
        from 
	        (select 
                tm.efin
            ,   tm.xmit_date TransmitDate
            ,   tm.[user_ID]
            ,   @season season
            ,   tm.bank_id
            ,	Count(CASE WHEN tm.irs_acc_cd = 'A' THEN 1 END) efiles
            ,	Count(CASE WHEN tm.irs_acc_cd = 'A' AND tm.isProtPlus = 1 THEN 1 END) prot_plus_acks 
            ,	Count(CASE WHEN tm.irs_acc_cd = 'R' THEN 1 END) rejects
            ,	Count(*) total_returns
            ,	Count(CASE WHEN tm.irs_acc_cd = 'A' AND (tm.ral_flag = '5' OR (tm.ral_flag = '3' AND tm.bank_stat = 'D')) THEN 1 END) tot_rac_cnt
            ,	Count(CASE WHEN tm.isProtPlus = 1 AND tm.irs_acc_cd = 'A' AND (tm.ral_flag = '5' OR (tm.ral_flag = '3' AND tm.bank_stat = 'D')) THEN 1 END) prot_plus_racs
            ,	Count(CASE WHEN tm.irs_acc_cd = 'A' AND (tm.ral_flag = '5' OR (tm.ral_flag = '3' AND tm.bank_stat = 'D')) AND tm.isFullyFunded = 1 THEN 1 END) racs_funded
            ,	Count(CASE WHEN	tm.irs_acc_cd = 'A' AND tm.isProtPlus = 1 AND (tm.ral_flag = '5' OR (tm.ral_flag = '3' AND tm.bank_stat = 'D')) AND tm.isFullyFunded = 1 THEN 1 END) protracs_funded
            from 
                dbo.tblTaxmast tm
            group by
                tm.efin
            ,   tm.bank_id
            ,   tm.[user_ID]
            ,   tm.xmit_date) AS a LEFT JOIN tblUser ON tblUser.user_ID = a.user_ID
*/





	DELETE FROM dbCrosslinkGlobal..user_stats WHERE 1 = 1;

	INSERT INTO dbCrosslinkGlobal..user_stats
	SELECT a.user_ID,
			a.season,
	        Sum(tot_ral_cnt),
	        Sum(unpaid_cnt),
	        Sum(booked_amt),
	        Sum(paid_amt),
	        Sum(unpaid_amt),
	        Sum(tot_rac_cnt),
			Sum(efiles),
			Sum(rejects),
			Sum(total_returns),
			Sum(tran_fee_pd_cnt),
			Sum(rals_funded),
			Sum(racs_funded),
			a.account,
			a.TransmitDate,
			Sum(prot_plus_acks),
			Sum(prot_plus_funded),
			Sum(prot_plus_apps),	
            Sum(tot_loan_advanced),
            Sum(tot_loan_outstanding),
            Sum(tot_RT_received),
            Sum(tot_RT_acknowledged),
            Sum(tot_unique_efiles),
            Sum(tot_acks),
            --case when isnull(sum(tot_acks),0) = 0 then 0 else  (sum(tot_unique_efiles) - sum(tot_acks)) / sum(tot_acks) * 100.0 end,
            --case when isnull(sum(tot_loan_advanced),0) = 0 then 0 else (sum(tot_loan_outstanding) / sum(tot_loan_advanced)) * 100.0 end,
            --case when isnull(sum(tot_RT_acknowledged),0) = 0 then 0 else (sum(tot_RT_received) / sum(tot_RT_acknowledged)) * 100.0 end rt_funding_rate

            convert(decimal(16,2),case when isnull(sum(a.tot_acks),0) = 0 and isnull(sum(a.tot_unique_efiles),0) != 0 then 100.0 when isnull(sum(a.tot_acks),0) = 0 then 0 else ((isnull(sum(a.tot_unique_efiles),0) - isnull(sum(a.tot_acks),0)) * 1.0) / isnull(sum(a.tot_acks),0) * 100.0 end) ultimate_reject_rate
        ,   convert(decimal(16,2),case when isnull(sum(a.tot_loan_advanced),0) = 0 then 0 else ((isnull(sum(a.tot_loan_outstanding),0) * 1.00) / (isnull(sum(a.tot_loan_advanced),0)) * 1.00) * 100.0 end) loss_rate
        ,   convert(decimal(16,2),case when isnull(sum(a.tot_RT_acknowledged),0) = 0 then 0 else (isnull(sum(a.tot_RT_received),0) / isnull(sum(a.tot_RT_acknowledged),0)) * 100.0 end) rt_funding_rate


	FROM dbCrosslinkGlobal..efin_stats a
	GROUP BY a.user_ID, a.account, a.season, a.TransmitDate

END
