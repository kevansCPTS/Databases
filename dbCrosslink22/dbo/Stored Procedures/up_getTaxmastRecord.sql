CREATE procedure [dbo].[up_getTaxmastRecord] 
    @pssn               int
as

    set nocount on

   select 
        tm.pssn
    ,   tm.irs_acc_cd
    ,   tm.irs_ack_dt
    ,   tm.irs_refund
    ,   tm.refund
    ,   tm.ral_flag
    ,   tm.tax_prep_fee [Tax Prep]
    ,   tm.pei_tran_fee      peiTran
    ,   tm.ero_tran_fee     eroTran
    ,   tm.req_tech_fee    Tech
    ,   tm.sb_prep_fee [SB Fee]
    ,   tm.req_acnt_fee [Bank Fee]
    ,   tm.doc_prep_fee   [Doc Fee]
    ,   tm.tot_elf_fee [EF Fee]
    ,   tm.ero_ef_fee [ERO EF Fee]
    ,   tm.tran_pay_amt [Transfer Payment]
    ,   isnull(tmf.reqAmount, 0) ancillary
    ,   la.state_rac [State RAC]
    ,   isnull(eb.StateAdminFee, 0) [State Admin Fee]
    ,   tm.split_disb_amt [Other Office Fee]
    ,   tm.elf_prep_fee [EF Prep Fee]
    ,   case 
            when tm.ral_flag = 5 then tm.refund - ( (convert(money, (tm.tax_prep_fee + tm.pei_tran_fee + tm.ero_tran_fee + tm.req_tech_fee 
            + tm.sb_prep_fee +  tm.req_acnt_fee + tm.doc_prep_fee + tm.ero_ef_fee + tm.elf_prep_fee)) / 100 ) + isnull(tmf.reqAmount, 0) +
                  case -- TPG document fees 
                    when tm.bank_id in ('S', 'W') then  
                            case
                            when tm.doc_prep_fee <= 100 then 0
                            when tm.doc_prep_fee <= 5001 then 5
                            when tm.doc_prep_fee <= 10001 then 7
                            else 10
                            end                     
                    else 0
                    end  + 
                case -- Refund Adv fees
                    when la.state_rac = 'Y' and tm.bank_id = 'V' then isnull(eb.StateAdminFee, 0) + (tm.split_disb_amt / 100)
                    when la.state_rac = 'N' and tm.bank_id = 'V' then (tm.split_disb_amt / 100)
                    else 0
                    end )
            else tm.refund
        end expectedRefund             
    from
        dbo.tblTaxmast tm left join dbo.EFINBank eb on tm.bank_id = eb.EFINBankID
        left join dbo.tblLoanapp la on la.pssn = tm.pssn
        left join (
                    select 
                        tmf1.pssn
                    ,   sum(tmf1.reqAmount) reqAmount
                    from
                        dbo.tblTaxmastFee tmf1                                                   
                    where
                        tmf1.pssn = @pssn
                        and tmf1.feeType in (1,2)
                    group by
                        tmf1.pssn
                  ) tmf on tm.pssn = tmf.pssn              
    where
        tm.pssn = @pssn
