


CREATE view [dbo].[vw_TaxReturnFees]
as
SELECT	
	*
,		case when requestedGrossEFFee > 0 then requestedGrossEFFee - requestedCPTSAdminEFFee
			 else 0
		end		requestedERONetEFFee
,		paidEROEFFee + paidEROTranFee + paidGrossFeePayAmt	paidEROCumulative
,		case when isbankprod = 1 then requestedGrossTranFee - requestedCPTSAdminFee	
			 when isbankprod = 0 and paidGrossTranPayAmt > 0 then requestedGrossTranFee - requestedCPTSAdminFee
			else 0 end	requestedERONetTranFee
,		paidCPTSTechAndTran + paidCPTSAdminFee + paidCPTSAdminEFFee + checkAdminFee paidCPTSCumulative
FROM (
	SELECT t.pssn
	,             t.user_id
	,             u.account
	,	t.efin
	,	t.pri_fname
	,	t.pri_lname
	,             convert(money, pei_tran_fee/100.0)											requestedCPTSTranFee
	,             convert(money, req_tech_fee/100.0)											requestedCPTSTechFee
	,             convert(money, ero_tran_fee/100.0)											requestedGrossTranFee
	,             convert(money, cpts_admin_fee/100.0)											requestedCPTSAdminFee
	,             convert(money, ero_ef_fee/100.0)												requestedGrossEFFee
	,             convert(money, case when ero_ef_fee > 0 then admin_ef_fee else 0 end/100.0)   requestedCPTSAdminEFFee
	,             convert(money, sb_prep_fee/100.0)												requestedSBPrepFee
	,             convert(money, tax_prep_fee/100.0)        									requestedTaxPrepFee
	,             convert(money, doc_prep_fee/100.0)        									requestedDocPrepFee
	,             convert(money, elf_prep_fee/100.0)        									requestedELFPrepFee
	,             convert(money, ero_bank_fee/100.0)        									requestedERPBankFee
	,             convert(money, req_acnt_fee/100.0)        									requestedAcntFee
	,             convert(money, split_disb_amt/100.0)      									requestedSplitDisbAmt

	,             isBankProd
	,             isFullyFunded
	,             fullyFundedDate

	,             convert(money, tran_pay_amt/100.0)        paidGrossTranPayAmt
	,             tran_pay_date
	,             convert(money, fee_pay_amt/100.0)         paidGrossFeePayAmt
	,             fee_pay_date
	,             convert(money, sb_pay_amt/100.0)          paidGrossSBPayAmt
	,             sb_pay_date

	,             CAST(CASE 
								 WHEN tran_pay_amt >= isnull(chk_adm_fee, 0) + pei_tran_fee + req_tech_fee THEN pei_tran_fee + req_tech_fee
								 ELSE tran_pay_amt - isnull(chk_adm_fee, 0)
				  END AS MONEY) / CAST(100 AS MONEY) paidCPTSTechAndTran

	,             CAST(CASE
								 WHEN tran_pay_amt >= isnull(chk_adm_fee, 0) + pei_tran_fee + req_tech_fee + ero_tran_fee THEN cpts_admin_fee
								 WHEN tran_pay_amt >= isnull(chk_adm_fee, 0) + pei_tran_fee + req_tech_fee + cpts_admin_fee THEN cpts_admin_fee
								 WHEN tran_pay_amt >  isnull(chk_adm_fee, 0) + pei_tran_fee + req_tech_fee THEN tran_pay_amt - pei_tran_fee - req_tech_fee - isnull(chk_adm_fee, 0)
								 ELSE 0
				  END AS MONEY)/ CAST(100 AS MONEY) paidCPTSAdminFee

	,             CAST(CASE WHEN ero_ef_fee > 0 THEN
								case when tran_pay_amt >= isnull(chk_adm_fee, 0) + pei_tran_fee + req_tech_fee + ero_tran_fee + ero_ef_fee THEN admin_ef_fee
									when tran_pay_amt > isnull(chk_adm_fee, 0) + pei_tran_fee + req_tech_fee + cpts_admin_fee + admin_ef_fee THEN admin_ef_fee
									when tran_pay_amt > isnull(chk_adm_fee, 0) + pei_tran_fee + req_tech_fee + cpts_admin_fee THEN tran_pay_amt - pei_tran_fee - req_tech_fee - cpts_admin_fee - isnull(chk_adm_fee, 0)
									else 0
								end
						ELSE 0
				  END AS MONEY) / CAST(100 AS MONEY) paidCPTSAdminEFFee

	,             CAST(CASE WHEN ero_tran_fee > 0 THEN
							case WHEN tran_pay_amt >= isnull(chk_adm_fee, 0) + pei_tran_fee + req_tech_fee + ero_tran_fee + ero_ef_fee THEN ero_tran_fee - cpts_admin_fee
								 WHEN tran_pay_amt >  isnull(chk_adm_fee, 0) + pei_tran_fee + req_tech_fee + ero_tran_fee + (case when ero_ef_fee = 0 then 0 else admin_ef_fee end) THEN ero_tran_fee - cpts_admin_fee
								 WHEN tran_pay_amt >  isnull(chk_adm_fee, 0) + pei_tran_fee + req_tech_fee + cpts_admin_fee + (case when ero_ef_fee = 0 then 0 else admin_ef_fee end) THEN tran_pay_amt - pei_tran_fee - req_tech_fee - cpts_admin_fee - (case when ero_ef_fee = 0 then
 0 else admin_ef_fee end) - isnull(chk_adm_fee, 0)
								 ELSE 0
							end
						else 0
				  END AS MONEY) / CAST(100 AS MONEY) paidEROTranFee

	,             CAST(CASE WHEN ero_ef_fee > 0 THEN
								case when tran_pay_amt >= isnull(chk_adm_fee, 0) + pei_tran_fee + req_tech_fee + ero_tran_fee + ero_ef_fee then ero_ef_fee - admin_ef_fee
									 when tran_pay_amt >  isnull(chk_adm_fee, 0) + pei_tran_fee + req_tech_fee + ero_tran_fee + admin_ef_fee then tran_pay_amt - pei_tran_fee - req_tech_fee - ero_tran_fee - admin_ef_fee - isnull(chk_adm_fee, 0)
									 else 0
								end
							else 0
				  END AS MONEY) / CAST(100 AS MONEY) paidEROEFFee

				  -- Check Fees
	,             CAST(isnull(chk_adm_fee, 0) AS MONEY) / CAST(100 AS MONEY) checkAdminFee
	,			  case when t.bank_id = 'F' then 'Refundo'
							 when t.bank_id = 'R' then 'Republic'
							 when t.bank_id = 'S' then 'TPG'
							 when t.bank_id = 'V' then 'Refund Advantage'
							 when t.bank_id = 'W' then 'World'
					   else 'No Bank'				
				  end Bank
	,			  case when t.ral_flag = '1' then 'IRS Paper Check'
					   when t.ral_flag = '2' then 'IRS Direct Deposit'
					   when t.ral_flag = '4' then 'Balance Due'
					   when t.ral_flag = '5' then 'Refund Transfer'
				  end RefundType
	,			  case when tran_pay_amt > 0 and isFullyFunded = 0 then 1
						else 0
				  end partiallyPaid
	,	t.irs_acc_cd
	,	case when t.irs_acc_cd = 'A' then 'Acknowledged'
	        when t.irs_acc_cd = 'R' then 'Rejected'
		end IRSAckCode
	,	t.irs_ack_dt
	,	isnull(chk_fee_cnt, 0)	chk_fee_cnt
	,	t.ret_stat
    ,   t.parentAccount
    ,   t.fdate
    ,   t.ral_flag
	,	r.PaidPreparerID
	,	r.PreparerName
	FROM   tbltaxmast t
	LEFT JOIN tblReturnMaster r on r.UserID = t.user_id and r.PrimarySSN = t.pssn and r.FilingStatus = t.filing_stat
	INNER JOIN dbcrosslinkglobal..tbluser u on u.user_id = t.user_id
	LEFT JOIN (
		   select	pssn
		   ,		sum(400) chk_adm_fee
		   ,		count(pssn) chk_fee_cnt
		   from   tbldisburse
		   where  prev_chk_num = 0
		   and (
						 aprod_tag1 = 'CAF'
		   or            aprod_tag2 = 'CAF'
		   or            aprod_tag3 = 'CAF'
		   or            aprod_tag4 = 'CAF' )
		   group by pssn
	) caf on caf.pssn = t.pssn
) a

