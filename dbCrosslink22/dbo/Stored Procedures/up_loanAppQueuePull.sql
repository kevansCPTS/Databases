







CREATE procedure [dbo].[up_loanAppQueuePull]
    @bankId char(1)
,   @statusIn char(1)
,   @statusOut char(1)
,   @batch char(9)
,   @batchSize int = 0
as


/*
declare @bankId char(1)
declare @statusIn char(1)
declare @statusOut char(1)
declare @batch char(9)
declare @batchSize int = 0

declare @lapplist table (
    pssn    int     NOT NULL
,   UNIQUE CLUSTERED (pssn) 
)


insert @lapplist
    select
        la.pssn
    from 
        dbo.tblLoanApp la
    where
        la.bank_id = @bankId    
        and la.[status] = 
*/


set nocount on


    if @batchSize is null
        set @batchSize = 0

    set rowcount @batchSize

    update la
        set la.[status] = @statusOut
    ,   la.batch = @batch
    from
        dbo.tblLoanApp la
    where
        la.bank_id = @bankId
        and la.[status] = @statusIn


    select
        la.pssn
    ,   la.bankapp_id
    ,   la.[status]
    ,   la.RejectCode
    ,   la.RejectDescription
    ,   la.[user_id]
    ,   la.user_spec
    ,   la.efin
    ,   la.[master]
    ,   la.site_id
    ,   la.pri_fname
    ,   la.pri_init
    ,   la.pri_lname
    ,   la.pri_dob
    ,   la.sec_ssn
    ,   la.sec_fname
    ,   la.sec_init
    ,   la.sec_lname
    ,   la.sec_dob
    ,   la.[address]
    ,   la.city
    ,   la.[state]
    ,   la.zip
    ,   la.res_address
    ,   la.res_city
    ,   la.res_state
    ,   la.res_zip
    ,   la.home_phone
    ,   la.work_phone
    ,   la.ral_flag
    ,   la.refund
    ,   la.bal_due
    ,   la.fld_1272
    ,   la.fld_1278
    ,   la.fld_1274
    ,   la.fld_1276
    ,   la.tot_income
    ,   la.tot_tax
    ,   la.tot_itw
    ,   la.tot_agi
    ,   la.tot_eic
    ,   la.tot_dep
    ,   la.fld_eicf
    ,   la.site_rej
    ,   la.verify_errors
    ,   la.import_errors
    ,   la.bank_id
    ,   la.pei_tran_fee
    ,   la.ero_tran_fee
    ,   la.sb_prep_fee
    ,   la.tax_prep_fee
    ,   la.ero_bank_fee
    ,   la.req_bank_fee
    ,   la.req_acnt_fee
    ,   la.pei_prot_fee
    ,   la.ero_prot_fee
    ,   la.req_tech_fee
    ,   la.req_loan_amt
    ,   la.verify_level
    ,   la.filing_stat
    ,   la.prep_ind
    ,   la.prep_id
    ,   la.cross_collect_ind
    ,   la.w2_ein
    ,   la.w2_cnt
    ,   la.ero_state
    ,   la.sig_date
    ,   la.all_state_rfnd
    ,   la.state_rac
    ,   la.pt_rtn
    ,   la.pt_dan
    ,   la.pt_acnt_type
    ,   la.cash_card
    ,   la.email_address
    ,   la.[guid]
    ,   la.rsrvd_ip_addr
    ,   la.irs_8453OL
    ,   la.verify_addr_ind
    ,   la.alt_addr_ind
    ,   la.alt_addr_descr
    ,   la.prim_1st_id_type
    ,   la.prim_1st_id_descr
    ,   la.prim_1st_id_nbr
    ,   la.prim_1st_id_place
    ,   la.prim_1st_id_issued
    ,   la.prim_1st_id_expire
    ,   la.prim_1st_id_info
    ,   la.prim_1st_id_dflag
    ,   la.prim_1st_id_dreas
    ,   la.prim_2nd_id_type
    ,   la.prim_2nd_id_descr
    ,   la.prim_2nd_id_nbr
    ,   la.prim_2nd_id_place
    ,   la.prim_2nd_id_issued
    ,   la.prim_2nd_id_expire
    ,   la.prim_2nd_id_dflag
    ,   la.prim_2nd_id_dreas
    ,   la.prim_3rd_id_type
    ,   la.prim_3rd_id_descr
    ,   la.prim_3rd_id_nbr
    ,   la.prim_3rd_id_place
    ,   la.prim_3rd_id_issued
    ,   la.prim_3rd_id_expire
    ,   la.prim_3rd_id_dflag
    ,   la.prim_3rd_id_dreas
    ,   la.sec_1st_id_type
    ,   la.sec_1st_id_descr
    ,   la.sec_1st_id_nbr
    ,   la.sec_1st_id_place
    ,   la.sec_1st_id_issued
    ,   la.sec_1st_id_expire
    ,   la.sec_1st_id_info
    ,   la.sec_1st_id_dflag
    ,   la.sec_1st_id_dreas
    ,   la.sec_2nd_id_type
    ,   la.sec_2nd_id_descr
    ,   la.sec_2nd_id_nbr
    ,   la.sec_2nd_id_place
    ,   la.sec_2nd_id_issued
    ,   la.sec_2nd_id_expire
    ,   la.sec_2nd_id_dflag
    ,   la.sec_2nd_id_dreas
    ,   la.sec_3rd_id_type
    ,   la.sec_3rd_id_descr
    ,   la.sec_3rd_id_nbr
    ,   la.sec_3rd_id_place
    ,   la.sec_3rd_id_issued
    ,   la.sec_3rd_id_expire
    ,   la.sec_3rd_id_dflag
    ,   la.sec_3rd_id_dreas
    ,   la.borr_ind
    ,   la.mil_ind
    ,   la.due_dil_ind
    ,   la.prot_plus
    ,   la.lexis_nexis
    ,   la.pref_contact
    ,   la.roll
    ,   la.ptin
    ,   la.esig_flag
    ,   la.dep_1_lname
    ,   la.dep_1_rel
    ,   la.dep_2_lname
    ,   la.dep_2_rel
    ,   la.dep_3_lname
    ,   la.dep_3_rel
    ,   la.dep_4_lname
    ,   la.dep_4_rel
    ,   la.wages
    ,   la.schc_incomeloss
    ,   la.other_gainloss
    ,   la.sche_incomeloss
    ,   la.farm_incomeloss
    ,   la.total_item_std_ded
    ,   la.child_tax_credit
    ,   la.edu_credit
    ,   la.est_tax_pay
    ,   la.occupation
    ,   la.eic_dep_1_lname
    ,   la.eic_dep_1_byear
    ,   la.eic_dep_1_rel
    ,   la.eic_dep_2_lname
    ,   la.eic_dep_2_byear
    ,   la.eic_dep_2_rel
    ,   la.eic_dep_3_lname
    ,   la.eic_dep_3_byear
    ,   la.eic_dep_3_rel
    ,   la.prim_secq
    ,   la.prim_seca
    ,   la.prim_lang
    ,   la.prim_contact_meth
    ,   la.prim_cell
    ,   la.prim_cell_carrier
    ,   la.prim_citizen
    ,   la.prim_citizen_country
    ,   la.sec_secq
    ,   la.sec_seca
    ,   la.sec_lang
    ,   la.sec_contact_meth
    ,   la.sec_cell
    ,   la.sec_cell_carrier
    ,   la.sec_citizen
    ,   la.sec_citizen_country
    ,   la.sec_email
    ,   la.fld_8836_ind
    ,   la.fld_8862_ind
    ,   la.sig_ver_user
    ,   la.sig_ver_disclose
    ,   la.sig_ver_bankapp
    ,   la.sig_ver_tila
    ,   la.advnt_sendsms
    ,   la.advnt_sendemail
    ,   la.disb_type
    ,   la.ext_pay_amt
    ,   la.fld_8379_ind
    ,   la.advnt_email_discl
    ,   la.req_rush_fee
    ,   la.req_phone_fee
    ,   la.split_disb_amt
    ,   la.ip_addr
    ,   la.insertDate
    ,   la.irs_acc_dt
    ,   la.irs_acc_cd
    ,   la.sub_date
    ,   la.resp_date
    ,   la.batch
    ,   la.elf_prep_fee
    ,   la.req_cadr_fee
    ,   la.doc_signer
    ,   la.doc_tp
    ,   la.doc_prep
    ,   la.bank_stat
    ,   la.adv_cmpid
    ,   la.adv_locid
    ,   la.adv_dstid
    ,   la.bnk_prim_id
    ,   la.bnk_sec_id
    ,   la.bnk_appid
    ,   la.form_type_1040
    ,   la.decline_code
    ,   la.submission_id
	,   la.req_utip_fee
	,	la.req_mmac_fee
	,   la.req_mmip_fee
	,   la.padp_flag
	,   la.doc_prep_fee
	,   la.elf_prep_fee
	,   la.rf_loan_ind
	,   la.fst_bnk_print_dt
	,   la.lst_bnk_print_dt
	,   la.cust_id_sha1
	,   la.rt_lite_ind
	,   la.fst_req_bank_fee
    ,   la.fst_req_acnt_fee
    ,   la.fst_req_loan_amt
    ,   la.fst_tax_prep_fee
    ,   la.fst_pei_tran_fee
    ,   la.fst_ero_tran_fee
    ,   la.fst_sb_prep_fee
    ,   la.fst_pei_prot_fee
    ,   la.fst_ero_prot_fee
    ,   la.fst_req_tech_fee
    ,   la.fst_prod_type
	,   la.lst_req_bank_fee
    ,   la.lst_req_acnt_fee
    ,   la.lst_req_loan_amt
    ,   la.lst_tax_prep_fee
    ,   la.lst_pei_tran_fee
    ,   la.lst_ero_tran_fee
    ,   la.lst_sb_prep_fee
    ,   la.lst_pei_prot_fee
    ,   la.lst_ero_prot_fee
    ,   la.lst_req_tech_fee
    ,   la.lst_prod_type
    ,   la.fst_aprod_tag1
    ,   la.fst_aprod_type1
    ,   la.fst_aprod_base1
    ,   la.fst_aprod_addon1
    ,   la.fst_aprod_tag2
    ,   la.fst_aprod_type2
    ,   la.fst_aprod_base2
    ,   la.fst_aprod_addon2
    ,   la.fst_aprod_tag3
    ,   la.fst_aprod_type3
    ,   la.fst_aprod_base3
    ,   la.fst_aprod_addon3
    ,   la.fst_aprod_tag4
    ,   la.fst_aprod_type4
    ,   la.fst_aprod_base4
    ,   la.fst_aprod_addon4
    ,   la.fst_aprod_tag5
    ,   la.fst_aprod_type5
    ,   la.fst_aprod_base5
    ,   la.fst_aprod_addon5
	,   la.fst_prim_ssn
	,   la.fst_sec_ssn
	,   la.ral_apr
	,   la.ral_finance_chrg
	,   la.admin_tran_fee
	,   la.cpts_ef_fee
	,   la.ero_ef_fee
	,   la.admin_ef_fee
	,   la.fst_cpts_ef_fee
	,   la.fst_ero_ef_fee
	,   la.fst_admin_ef_fee
    from
        dbo.tblLoanApp la
    where   
        la.[status] = @statusOut
        and la.batch = @batch
        and la.bank_id = @bankId
        

    set rowcount 0










