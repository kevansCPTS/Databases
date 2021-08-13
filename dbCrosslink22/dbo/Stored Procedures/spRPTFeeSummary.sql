


-- =============================================
-- Author:        Charles Krebs
-- Create date: 7/7/2011
-- Description:   Rebuild the RPTFeeSummary table with 
-- the fee values from tblTaxMaster
-- Updated 1/7/2014 Charles Krebs
-- Added new payment fields for PP and CADR+
-- =============================================
CREATE PROCEDURE [dbo].[spRPTFeeSummary]
AS

    set nocount on

    delete from dbo.RPTFeeSummary

    insert dbo.RPTFeeSummary
        select
            tm.pssn
        ,   u.Account
        ,   tm.[user_id] UserId
        ,   tm.Efin
        ,   isnull(cast(tm.tax_prep_fee as float), 0) / cast(100 as float) TaxPrepFee
        ,   isnull(cast(req_tech_fee as float), 0) / cast(100 as float) ReqTechFee   
        ,   isnull(f.ppPEIReqFee,0.00) PEIProtFee
        ,   isnull(f.ppEROReqFee,0.00) EROProtFee
        ,   isnull(cast(tm.pei_tran_fee as float), 0) / cast(100 as float) PEITranFee
        /*
        ,   case 
                when tm.isFullyFunded = 1 then tm.ero_tran_fee
                else tm.tran_pay_amt - tm.pei_tran_fee - tm.req_tech_fee
            end / 100.00 EROTranFee
        ,   case 
                when tm.isFullyFunded = 1 then tm.ero_tran_fee - tm.cpts_admin_fee
                else tm.tran_pay_amt - tm.pei_tran_fee - tm.req_tech_fee - tm.cpts_admin_fee
            end / 100.00 EROTranFee
        */
        ,	case when tm.tran_pay_amt >= tm.pei_tran_fee + tm.req_tech_fee + tm.ero_tran_fee + isnull((caf.chk_adm_fee * 100),0.00) then tm.ero_tran_fee - tm.cpts_admin_fee
				 when tm.tran_pay_amt < tm.pei_tran_fee + tm.req_tech_fee + tm.cpts_admin_fee + isnull((caf.chk_adm_fee * 100),0.00) then tm.tran_pay_amt - tm.pei_tran_fee - tm.req_tech_fee - tm.cpts_admin_fee - isnull((caf.chk_adm_fee * 100),0.00)
				 else 0
			end / 100.00 ero_tran_fee_net
        ,   isnull(cast(tm.fee_pay_amt as float), 0) / cast(100 as float) FeePayAmount
        ,   isnull(cast(tm.tran_pay_amt as float), 0) / cast(100 as float) TranPayAmount
        ,   tm.tran_pay_date PayDate 
        ,   isnull(cast(tm.sb_pay_amt as float), 0) / cast(100 as float) SBPayAmount
        ,   isnull(cast(tm.sb_prep_fee as float), 0) / CAST(100 as float) SBPrepFee
        ,   isnull(f.ppPayAmt,0.00) PPPayAmount
        ,   f.ppPayDate PPPayDate
        ,   0.00 CADRPayAmount
        ,   null CADRPayDate
        ,   0.00 ReqCADRFee
        ,   isnull(cast(tm.cpts_admin_fee as float), 0) / CAST(100 as float) CPTSAdminFee
        ,   isnull(caf.chk_adm_fee,0.00) ChkAdminFee
        ,   isnull(tm.doc_prep_fee,0.00) / CAST(100 as float) DocPrepFee
        ,   isnull(tm.elf_prep_fee,0.00) / CAST(100 as float) ELFPRepFee
        ,   isnull(tm.admin_ef_fee,0.00) / CAST(100 as float) CPTS_Ef_Fee
        
        from
            dbo.tblTaxmast tm join dbCrosslinkGlobal.dbo.tblUser u on tm.[user_id] = u.[user_id]
                and tm.tran_pay_amt > 0
                and tm.tran_pay_amt > tm.pei_tran_fee + tm.req_tech_fee	+ tm.cpts_admin_fee
            left join (
                        select
                            tmf1.pssn
                        ,   sum(case when tmf1.tag = 'AUD' and tmf1.feeType = 1 then tmf1.reqAmount end) ppPEIReqFee
                        ,   sum(case when tmf1.tag = 'AUD' and tmf1.feeType = 2 then tmf1.reqAmount end) ppEROReqFee
                        ,   sum(case when tmf1.tag = 'AUD' then tmf1.payAmount end) ppPayAmt
                        ,   max(case when tmf1.tag = 'AUD' then tmf1.payDate end) ppPayDate
                        from    
                            dbo.tblTaxmastFee tmf1 
                        where
                            tmf1.tag = 'AUD'
                        group by
                            tmf1.pssn
                      ) f on tm.pssn = f.pssn
            left join (
                            select 
                                d1.pssn
                            ,   sum(4.00) chk_adm_fee
                            from   
                                dbo.tbldisburse d1
                            where  
                                d1.prev_chk_num = 0
                                and (
                                        d1.aprod_tag1 = 'CAF'
                                            or d1.aprod_tag2 = 'CAF'
                                            or d1.aprod_tag3 = 'CAF'
                                            or d1.aprod_tag4 = 'CAF' 
                                    )
                            group by 
                                d1.pssn

                        /*
                        select
                            tm1.pssn
                        ,   sum(case 
							    when d.chk_date >= tm1.irs_ack_dt and (tm1.irs_pay_date is not null and tm1.sta_pay_date2 is not null and tm1.sta_pay_date3 is not null and tm1.irs_pay_date is not null) then 4.00
							    when d.chk_date >= tm1.irs_ack_dt and (d.chk_date >= tm1.sta_pay_date1 or d.chk_date >= tm1.sta_pay_date2 or d.chk_date >= tm1.sta_pay_date3 or d.chk_date >= tm1.irs_pay_date) then 4.00
                                else 0.00
                            end) chk_adm_fee
                        from   
                            dbo.tbltaxmast tm1 join dbCrosslinkGlobal.dbo.tblUser u on tm1.[user_id] = u.[user_id] 
                                and tm1.tran_pay_amt > tm1.pei_tran_fee + tm1.req_tech_fee
                            join dbo.tblDisburse d on tm1.pssn = d.pssn
                                and d.prev_chk_num = 0 
                                and d.chk_type not in ('A', 'B', 'K', 'W') 
                                and d.chk_amt != 0
                            join dbo.tbltaxmastfee tmf on tm1.pssn = tmf.pssn
                                and tmf.tag = 'CAF' 
                                and tmf.feeType = 1
                        group by
                            tm1.pssn
                        */
    
                      ) caf on tm.pssn = caf.pssn

