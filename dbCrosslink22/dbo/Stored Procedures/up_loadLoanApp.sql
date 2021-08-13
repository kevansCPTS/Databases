







CREATE procedure [dbo].[up_loadLoanApp]
                @pssn int
            ,   @bankapp_id int
            ,   @status char(1)
            ,   @RejectCode varchar(50)
			,   @RejectDescription varchar(255)
            ,   @user_id int
            ,   @user_spec int 
            ,   @efin int
            ,   @master int 
            ,   @site_id char(7)
            ,   @pri_fname char(16)
            ,   @pri_init char(1)
            ,   @pri_lname char(32)
            ,   @pri_dob char(8)
            ,   @sec_ssn int
            ,   @sec_fname char(16)
            ,   @sec_init char(1)
            ,   @sec_lname char(32)
            ,   @sec_dob char(8)
            ,   @address char(35)
            ,   @city char(22)
            ,   @state char(2)
            ,   @zip char(12)
            ,   @res_address char(35)
            ,   @res_city char(22)
            ,   @res_state char(2)
            ,   @res_zip char(12)
            ,   @home_phone char(10)
            ,   @work_phone char(10)
            ,   @ral_flag char(1)
            ,   @refund int
            ,   @bal_due int
            ,   @fld_1272 char(9)
            ,   @fld_1278 char(17)
            ,   @fld_1274 char(1)
            ,   @fld_1276 char(1)
            ,   @tot_income int
            ,   @tot_tax int
            ,   @tot_itw int
            ,   @tot_agi int
            ,   @tot_eic smallint
            ,   @tot_dep smallint
            ,   @fld_eicf char(1)
            ,   @site_rej char(1)
            ,   @verify_errors smallint
            ,   @import_errors smallint
            ,   @bank_id char(1)
            ,   @pei_tran_fee int
            ,   @ero_tran_fee int
            ,   @sb_prep_fee int
            ,   @tax_prep_fee int
            ,   @ero_bank_fee int
            ,   @req_bank_fee int
            ,   @req_acnt_fee int
            ,   @pei_prot_fee int
            ,   @ero_prot_fee int
            ,   @req_tech_fee int
            ,   @req_loan_amt int
            ,   @verify_level smallint
            ,   @filing_stat char(1)
            ,   @prep_ind char(1)
            ,   @prep_id char(8)
            ,   @cross_collect_ind char(1)
            ,   @w2_ein int
            ,   @w2_cnt smallint
            ,   @ero_state char(2)
            ,   @sig_date char(8)
            ,   @all_state_rfnd int
            ,   @state_rac char(1)
            ,   @pt_rtn char(9)
            ,   @pt_dan char(17)
            ,   @pt_acnt_type char(1)
            ,   @cash_card char(17)
            ,   @email_address char(44)
            ,   @guid char(32)
            ,   @rsrvd_ip_addr char(1)
            ,   @irs_8453OL char(1)
            ,   @verify_addr_ind char(1)
            ,   @alt_addr_ind char(1)
            ,   @alt_addr_descr char(30)
            ,   @prim_1st_id_type char(1)
            ,   @prim_1st_id_descr char(20)
            ,   @prim_1st_id_nbr char(20)
            ,   @prim_1st_id_place char(22)
            ,   @prim_1st_id_issued char(8)
            ,   @prim_1st_id_expire char(8)
            ,   @prim_1st_id_info char(35)
            ,   @prim_1st_id_dflag char(1)
            ,   @prim_1st_id_dreas char(20)
            ,   @prim_2nd_id_type char(1)
            ,   @prim_2nd_id_descr char(52)
            ,   @prim_2nd_id_nbr char(20)
            ,   @prim_2nd_id_place char(22)
            ,   @prim_2nd_id_issued char(8)
            ,   @prim_2nd_id_expire char(8)
            ,   @prim_2nd_id_dflag char(1)
            ,   @prim_2nd_id_dreas char(20)
            ,   @prim_3rd_id_type char(1)
            ,   @prim_3rd_id_descr char(52)
            ,   @prim_3rd_id_nbr char(20)
            ,   @prim_3rd_id_place char(22)
            ,   @prim_3rd_id_issued char(8)
            ,   @prim_3rd_id_expire char(8)
            ,   @prim_3rd_id_dflag char(1)
            ,   @prim_3rd_id_dreas char(20)
            ,   @sec_1st_id_type char(1)
            ,   @sec_1st_id_descr char(20)
            ,   @sec_1st_id_nbr char(20)
            ,   @sec_1st_id_place char(22)
            ,   @sec_1st_id_issued char(8)
            ,   @sec_1st_id_expire char(8)
            ,   @sec_1st_id_info char(35)
            ,   @sec_1st_id_dflag char(1)
            ,   @sec_1st_id_dreas char(20)
            ,   @sec_2nd_id_type char(1)
            ,   @sec_2nd_id_descr char(52)
            ,   @sec_2nd_id_nbr char(20)
            ,   @sec_2nd_id_place char(22)
            ,   @sec_2nd_id_issued char(8)
            ,   @sec_2nd_id_expire char(8)
            ,   @sec_2nd_id_dflag char(1)
            ,   @sec_2nd_id_dreas char(20)
            ,   @sec_3rd_id_type char(1)
            ,   @sec_3rd_id_descr char(52)
            ,   @sec_3rd_id_nbr char(20)
            ,   @sec_3rd_id_place char(22)
            ,   @sec_3rd_id_issued char(8)
            ,   @sec_3rd_id_expire char(8)
            ,   @sec_3rd_id_dflag char(1)
            ,   @sec_3rd_id_dreas char(20)
            ,   @borr_ind char(1)
            ,   @mil_ind char(1)
            ,   @due_dil_ind char(1)
            ,   @prot_plus char(1)
            ,   @lexis_nexis char(1)
            ,   @pref_contact char(1)
            ,   @roll char(1)
            ,   @ptin char(9)
            ,   @esig_flag char(1)
            ,   @dep_1_lname char(15)
            ,   @dep_1_rel char(11)
            ,   @dep_2_lname char(15)
            ,   @dep_2_rel char(11)
            ,   @dep_3_lname char(15)
            ,   @dep_3_rel char(11)
            ,   @dep_4_lname char(15)
            ,   @dep_4_rel char(11)
            ,   @wages int
            ,   @schc_incomeloss int
            ,   @other_gainloss int
            ,   @sche_incomeloss int
            ,   @farm_incomeloss int
            ,   @total_item_std_ded int
            ,   @child_tax_credit int
            ,   @edu_credit int
            ,   @est_tax_pay int
            ,   @occupation char(25)
            ,   @eic_dep_1_lname char(15)
            ,   @eic_dep_1_byear char(4)
            ,   @eic_dep_1_rel char(11)
            ,   @eic_dep_2_lname char(15)
            ,   @eic_dep_2_byear char(4)
            ,   @eic_dep_2_rel char(11)
            ,   @eic_dep_3_lname char(15)
            ,   @eic_dep_3_byear char(4)
            ,   @eic_dep_3_rel char(11)
            ,   @prim_secq char(1)
            ,   @prim_seca char(25)
            ,   @prim_lang char(1)
            ,   @prim_contact_meth char(1)
            ,   @prim_cell char(10)
            ,   @prim_cell_carrier char(2)
            ,   @prim_citizen char(1)
            ,   @prim_citizen_country char(20)
            ,   @sec_secq char(1)
            ,   @sec_seca char(25)
            ,   @sec_lang char(1)
            ,   @sec_contact_meth char(1)
            ,   @sec_cell char(10)
            ,   @sec_cell_carrier char(2)
            ,   @sec_citizen char(1)
            ,   @sec_citizen_country char(20)
            ,   @sec_email char(44)
            ,   @fld_8836_ind char(1)
            ,   @fld_8862_ind char(1)
            ,   @sig_ver_user char(1)
            ,   @sig_ver_disclose char(1)
            ,   @sig_ver_bankapp char(1)
            ,   @sig_ver_tila char(1)
            ,   @advnt_sendsms char(1)
            ,   @advnt_sendemail char(1)
            ,   @disb_type char(1)
            ,   @ext_pay_amt int
            ,   @fld_8379_ind char(1)
            ,   @advnt_email_discl char(1)
            ,   @req_rush_fee int
            ,   @req_phone_fee int
            ,   @split_disb_amt int
            ,   @ip_addr char(15)
            ,   @insertDate datetime
            ,   @irs_acc_dt datetime
            ,   @irs_acc_cd char(1)
            ,   @sub_date datetime
            ,   @resp_date datetime
            ,   @batch char(9)
            ,   @elf_prep_fee int
            ,   @req_cadr_fee int
            ,   @doc_signer varchar(22)
            ,   @doc_tp char(1)
            ,   @doc_prep char(1)
            ,   @bank_stat char(1)
            ,   @adv_cmpid int
            ,   @adv_locid int
            ,   @adv_dstid int
            ,   @bnk_prim_id int
            ,   @bnk_sec_id int
            ,   @bnk_appid int
            ,   @form_type_1040 char(1)
            ,   @decline_code int
            ,   @submission_id varchar(20)
            ,   @req_utip_fee int
            ,   @req_mmac_fee int
            ,   @req_mmip_fee int
            ,   @padp_flag char(1)
            ,   @rf_loan_ind char(1)
            ,   @doc_prep_fee int
            ,   @fst_bnk_print_dt datetime
            ,   @lst_bnk_print_dt datetime
            ,   @cust_id_sha1 char(40)
            ,   @rt_lite_ind char(1)
            ,   @fst_req_bank_fee int
            ,   @fst_req_acnt_fee int
            ,   @fst_req_loan_amt int
            ,   @fst_tax_prep_fee int
            ,   @fst_pei_tran_fee int
            ,   @fst_ero_tran_fee int
            ,   @fst_sb_prep_fee int
            ,   @fst_pei_prot_fee int
            ,   @fst_ero_prot_fee int
            ,   @fst_req_tech_fee int
            ,   @fst_prod_type char(1)
            ,   @lst_req_bank_fee int
            ,   @lst_req_acnt_fee int
            ,   @lst_req_loan_amt int
            ,   @lst_tax_prep_fee int
            ,   @lst_pei_tran_fee int
            ,   @lst_ero_tran_fee int
            ,   @lst_sb_prep_fee int
            ,   @lst_pei_prot_fee int
            ,   @lst_ero_prot_fee int
            ,   @lst_req_tech_fee int
            ,   @lst_prod_type char(1)
            ,   @fst_aprod_tag1 char(3)
            ,   @fst_aprod_type1 tinyint
            ,   @fst_aprod_base1 int
            ,   @fst_aprod_addon1 int
            ,   @fst_aprod_tag2 char(3)
            ,   @fst_aprod_type2 tinyint
            ,   @fst_aprod_base2 int
            ,   @fst_aprod_addon2 int
            ,   @fst_aprod_tag3 char(3)
            ,   @fst_aprod_type3 tinyint
            ,   @fst_aprod_base3 int
            ,   @fst_aprod_addon3 int
            ,   @fst_aprod_tag4 char(3)
            ,   @fst_aprod_type4 tinyint
            ,   @fst_aprod_base4 int
            ,   @fst_aprod_addon4 int
            ,   @fst_aprod_tag5 char(3)
            ,   @fst_aprod_type5 tinyint
            ,   @fst_aprod_base5 int
            ,   @fst_aprod_addon5 int
            ,   @fst_prim_ssn int
            ,   @fst_sec_ssn int
            ,   @ral_apr int
            ,   @ral_finance_chrg int
            ,   @admin_tran_fee int
            ,   @cpts_ef_fee int
            ,   @ero_ef_fee int
            ,   @admin_ef_fee int
            ,   @fst_cpts_ef_fee int
            ,   @fst_ero_ef_fee int
            ,   @fst_admin_ef_fee int

as

  UPDATE [dbo].[tblLoanApp] SET [bankapp_id] = @bankapp_id
                      --,[status] = @status
                      --,[RejectCode] = @rejectcode
                      --,[RejectDescription] = @rejectdescription
                      ,[user_id] = @user_id
                      ,[user_spec] = @user_spec
                      ,[efin] = @efin
                      ,[master] = @master
                      ,[site_id] = @site_id
                      ,[pri_fname] = @pri_fname
                      ,[pri_init] = @pri_init
                      ,[pri_lname] = @pri_lname
                      ,[pri_dob] = @pri_dob
                      ,[sec_ssn] = @sec_ssn
                      ,[sec_fname] = @sec_fname
                      ,[sec_init] = @sec_init
                      ,[sec_lname] = @sec_lname
                      ,[sec_dob] = @sec_dob
                      ,[address] = @address
                      ,[city] = @city
                      ,[state] = @state
                      ,[zip] = @zip
                      ,[res_address] = @res_address
                      ,[res_city] = @res_city
                      ,[res_state] = @res_state
                      ,[res_zip] = @res_zip
                      ,[home_phone] = @home_phone
                      ,[work_phone] = @work_phone
                      ,[ral_flag] = @ral_flag
                      ,[refund] = @refund
                      ,[bal_due] = @bal_due
                      ,[fld_1272] = @fld_1272
                      ,[fld_1278] = @fld_1278
                      ,[fld_1274] = @fld_1274
                      ,[fld_1276] = @fld_1276
                      ,[tot_income] = @tot_income
                      ,[tot_tax] = @tot_tax
                      ,[tot_itw] = @tot_itw
                      ,[tot_agi] = @tot_agi
                      ,[tot_eic] = @tot_eic
                      ,[tot_dep] = @tot_dep
                      ,[fld_eicf] = @fld_eicf
                      ,[site_rej] = @site_rej
                      ,[verify_errors] = @verify_errors
                      ,[import_errors] = @import_errors
                      ,[bank_id] = @bank_id
                      ,[pei_tran_fee] = @pei_tran_fee
                      ,[ero_tran_fee] = @ero_tran_fee
                      ,[sb_prep_fee] = @sb_prep_fee
                      ,[tax_prep_fee] = @tax_prep_fee
                      ,[ero_bank_fee] = @ero_bank_fee
                      ,[req_bank_fee] = @req_bank_fee
                      ,[req_acnt_fee] = @req_acnt_fee
                      ,[pei_prot_fee] = @pei_prot_fee
                      ,[ero_prot_fee] = @ero_prot_fee
                      ,[req_tech_fee] = @req_tech_fee
                      ,[req_loan_amt] = @req_loan_amt
                      ,[verify_level] = @verify_level
                      ,[filing_stat] = @filing_stat
                      ,[prep_ind] = @prep_ind
                      ,[prep_id] = @prep_id
                      ,[cross_collect_ind] = @cross_collect_ind
                      ,[w2_ein] = @w2_ein
                      ,[w2_cnt] = @w2_cnt
                      ,[ero_state] = @ero_state
                      ,[sig_date] = @sig_date
                      ,[all_state_rfnd] = @all_state_rfnd
                      ,[state_rac] = @state_rac
                      ,[pt_rtn] = @pt_rtn
                      ,[pt_dan] = @pt_dan
                      ,[pt_acnt_type] = @pt_acnt_type
                      ,[cash_card] = @cash_card
                      ,[email_address] = @email_address
                      ,[guid] = @guid
                      ,[rsrvd_ip_addr] = @rsrvd_ip_addr
                      ,[irs_8453OL] = @irs_8453ol
                      ,[verify_addr_ind] = @verify_addr_ind
                      ,[alt_addr_ind] = @alt_addr_ind
                      ,[alt_addr_descr] = @alt_addr_descr
                      ,[prim_1st_id_type] = @prim_1st_id_type
                      ,[prim_1st_id_descr] = @prim_1st_id_descr
                      ,[prim_1st_id_nbr] = @prim_1st_id_nbr
                      ,[prim_1st_id_place] = @prim_1st_id_place
                      ,[prim_1st_id_issued] = @prim_1st_id_issued
                      ,[prim_1st_id_expire] = @prim_1st_id_expire
                      ,[prim_1st_id_info] = @prim_1st_id_info
                      ,[prim_1st_id_dflag] = @prim_1st_id_dflag
                      ,[prim_1st_id_dreas] = @prim_1st_id_dreas
                      ,[prim_2nd_id_type] = @prim_2nd_id_type
                      ,[prim_2nd_id_descr] = @prim_2nd_id_descr
                      ,[prim_2nd_id_nbr] = @prim_2nd_id_nbr
                      ,[prim_2nd_id_place] = @prim_2nd_id_place
                      ,[prim_2nd_id_issued] = @prim_2nd_id_issued
                      ,[prim_2nd_id_expire] = @prim_2nd_id_expire
                      ,[prim_2nd_id_dflag] = @prim_2nd_id_dflag
                      ,[prim_2nd_id_dreas] = @prim_2nd_id_dreas
                      ,[prim_3rd_id_type] = @prim_3rd_id_type
                      ,[prim_3rd_id_descr] = @prim_3rd_id_descr
                      ,[prim_3rd_id_nbr] = @prim_3rd_id_nbr
                      ,[prim_3rd_id_place] = @prim_3rd_id_place
                      ,[prim_3rd_id_issued] = @prim_3rd_id_issued
                      ,[prim_3rd_id_expire] = @prim_3rd_id_expire
                      ,[prim_3rd_id_dflag] = @prim_3rd_id_dflag
                      ,[prim_3rd_id_dreas] = @prim_3rd_id_dreas
                      ,[sec_1st_id_type] = @sec_1st_id_type
                      ,[sec_1st_id_descr] = @sec_1st_id_descr
                      ,[sec_1st_id_nbr] = @sec_1st_id_nbr
                      ,[sec_1st_id_place] = @sec_1st_id_place
                      ,[sec_1st_id_issued] = @sec_1st_id_issued
                      ,[sec_1st_id_expire] = @sec_1st_id_expire
                      ,[sec_1st_id_info] = @sec_1st_id_info
                      ,[sec_1st_id_dflag] = @sec_1st_id_dflag
                      ,[sec_1st_id_dreas] = @sec_1st_id_dreas
                      ,[sec_2nd_id_type] = @sec_2nd_id_type
                      ,[sec_2nd_id_descr] = @sec_2nd_id_descr
                      ,[sec_2nd_id_nbr] = @sec_2nd_id_nbr
                      ,[sec_2nd_id_place] = @sec_2nd_id_place
                      ,[sec_2nd_id_issued] = @sec_2nd_id_issued
                      ,[sec_2nd_id_expire] = @sec_2nd_id_expire
                      ,[sec_2nd_id_dflag] = @sec_2nd_id_dflag
                      ,[sec_2nd_id_dreas] = @sec_2nd_id_dreas
                      ,[sec_3rd_id_type] = @sec_3rd_id_type
                      ,[sec_3rd_id_descr] = @sec_3rd_id_descr
                      ,[sec_3rd_id_nbr] = @sec_3rd_id_nbr
                      ,[sec_3rd_id_place] = @sec_3rd_id_place
                      ,[sec_3rd_id_issued] = @sec_3rd_id_issued
                      ,[sec_3rd_id_expire] = @sec_3rd_id_expire
                      ,[sec_3rd_id_dflag] = @sec_3rd_id_dflag
                      ,[sec_3rd_id_dreas] = @sec_3rd_id_dreas
                      ,[borr_ind] = @borr_ind
                      ,[mil_ind] = @mil_ind
                      ,[due_dil_ind] = @due_dil_ind
                      ,[prot_plus] = @prot_plus
                      ,[lexis_nexis] = @lexis_nexis
                      ,[pref_contact] = @pref_contact
                      ,[roll] = @roll
                      ,[ptin] = @ptin
                      ,[esig_flag] = @esig_flag
                      ,[dep_1_lname] = @dep_1_lname
                      ,[dep_1_rel] = @dep_1_rel
                      ,[dep_2_lname] = @dep_2_lname
                      ,[dep_2_rel] = @dep_2_rel
                      ,[dep_3_lname] = @dep_3_lname
                      ,[dep_3_rel] = @dep_3_rel
                      ,[dep_4_lname] = @dep_4_lname
                      ,[dep_4_rel] = @dep_4_rel
                      ,[wages] = @wages
                      ,[schc_incomeloss] = @schc_incomeloss
                      ,[other_gainloss] = @other_gainloss
                      ,[sche_incomeloss] = @sche_incomeloss
                      ,[farm_incomeloss] = @farm_incomeloss
                      ,[total_item_std_ded] = @total_item_std_ded
                      ,[child_tax_credit] = @child_tax_credit
                      ,[edu_credit] = @edu_credit
                      ,[est_tax_pay] = @est_tax_pay
                      ,[occupation] = @occupation
                      ,[eic_dep_1_lname] = @eic_dep_1_lname
                      ,[eic_dep_1_byear] = @eic_dep_1_byear
                      ,[eic_dep_1_rel] = @eic_dep_1_rel
                      ,[eic_dep_2_lname] = @eic_dep_2_lname
                      ,[eic_dep_2_byear] = @eic_dep_2_byear
                      ,[eic_dep_2_rel] = @eic_dep_2_rel
                      ,[eic_dep_3_lname] = @eic_dep_3_lname
                      ,[eic_dep_3_byear] = @eic_dep_3_byear
                      ,[eic_dep_3_rel] = @eic_dep_3_rel
                      ,[prim_secq] = @prim_secq
                      ,[prim_seca] = @prim_seca
                      ,[prim_lang] = @prim_lang
                      ,[prim_contact_meth] = @prim_contact_meth
                      ,[prim_cell] = @prim_cell
                      ,[prim_cell_carrier] = @prim_cell_carrier
                      ,[prim_citizen] = @prim_citizen
                      ,[prim_citizen_country] = @prim_citizen_country
                      ,[sec_secq] = @sec_secq
                      ,[sec_seca] = @sec_seca
                      ,[sec_lang] = @sec_lang
                      ,[sec_contact_meth] = @sec_contact_meth
                      ,[sec_cell] = @sec_cell
                      ,[sec_cell_carrier] = @sec_cell_carrier
                      ,[sec_citizen] = @sec_citizen
                      ,[sec_citizen_country] = @sec_citizen_country
                      ,[sec_email] = @sec_email
                      ,[fld_8836_ind] = @fld_8836_ind
                      ,[fld_8862_ind] = @fld_8862_ind
                      ,[sig_ver_user] = @sig_ver_user
                      ,[sig_ver_disclose] = @sig_ver_disclose
                      ,[sig_ver_bankapp] = @sig_ver_bankapp
                      ,[sig_ver_tila] = @sig_ver_tila
                      ,[advnt_sendsms] = @advnt_sendsms
                      ,[advnt_sendemail] = @advnt_sendemail
                      ,[disb_type] = @disb_type
                      ,[ext_pay_amt] = @ext_pay_amt
                      ,[fld_8379_ind] = @fld_8379_ind
                      ,[advnt_email_discl] = @advnt_email_discl
                      ,[req_rush_fee] = @req_rush_fee
                      ,[req_phone_fee] = @req_phone_fee
                      ,[split_disb_amt] = @split_disb_amt
                      ,[ip_addr] = @ip_addr
                      ,[insertDate] = @insertdate
                      ,[irs_acc_dt] = @irs_acc_dt
                      ,[irs_acc_cd] = @irs_acc_cd
                      ,[sub_date] = @sub_date
                      ,[resp_date] = @resp_date
                      ,[batch] = @batch
                      ,[elf_prep_fee] = @elf_prep_fee
                      ,[req_cadr_fee] = @req_cadr_fee
                      ,[doc_signer] = @doc_signer
                      ,[doc_tp] = @doc_tp
                      ,[doc_prep] = @doc_prep
                      --,[bank_stat] = @bank_stat
                      ,[adv_cmpid] = @adv_cmpid
                      ,[adv_locid] = @adv_locid
                      ,[adv_dstid] = @adv_dstid
                      ,[bnk_prim_id] = @bnk_prim_id
                      ,[bnk_sec_id] = @bnk_sec_id
                      ,[bnk_appid] = @bnk_appid
                      ,[form_type_1040] = @form_type_1040
                      ,[decline_code] = @decline_code
                      ,[submission_id] = @submission_id
                      ,[req_utip_fee] = @req_utip_fee
                      ,[req_mmac_fee] = @req_mmac_fee
                      ,[req_mmip_fee] = @req_mmip_fee
                      ,[padp_flag] = @padp_flag
                      ,[rf_loan_ind] = @rf_loan_ind
                      ,[doc_prep_fee] = @doc_prep_fee
                      ,[fst_bnk_print_dt] = @fst_bnk_print_dt
                      ,[lst_bnk_print_dt] = @lst_bnk_print_dt
                      ,[cust_id_sha1] = @cust_id_sha1
                      ,[rt_lite_ind] = @rt_lite_ind
                      ,[fst_req_bank_fee] = @fst_req_bank_fee
                      ,[fst_req_acnt_fee] = @fst_req_acnt_fee
                      ,[fst_req_loan_amt] = @fst_req_loan_amt
                      ,[fst_tax_prep_fee] = @fst_tax_prep_fee
                      ,[fst_pei_tran_fee] = @fst_pei_tran_fee
                      ,[fst_ero_tran_fee] = @fst_ero_tran_fee
                      ,[fst_sb_prep_fee] = @fst_sb_prep_fee
                      ,[fst_pei_prot_fee] = @fst_pei_prot_fee
                      ,[fst_ero_prot_fee] = @fst_ero_prot_fee
                      ,[fst_req_tech_fee] = @fst_req_tech_fee
                      ,[fst_prod_type] = @fst_prod_type
                      ,[lst_req_bank_fee] = @lst_req_bank_fee
                      ,[lst_req_acnt_fee] = @lst_req_acnt_fee
                      ,[lst_req_loan_amt] = @lst_req_loan_amt
                      ,[lst_tax_prep_fee] = @lst_tax_prep_fee
                      ,[lst_pei_tran_fee] = @lst_pei_tran_fee
                      ,[lst_ero_tran_fee] = @lst_ero_tran_fee
                      ,[lst_sb_prep_fee] = @lst_sb_prep_fee
                      ,[lst_pei_prot_fee] = @lst_pei_prot_fee
                      ,[lst_ero_prot_fee] = @lst_ero_prot_fee
                      ,[lst_req_tech_fee] = @lst_req_tech_fee
                      ,[lst_prod_type] = @lst_prod_type
                      ,[fst_aprod_tag1] = @fst_aprod_tag1
                      ,[fst_aprod_type1] = @fst_aprod_type1
                      ,[fst_aprod_base1] = @fst_aprod_base1
                      ,[fst_aprod_addon1] = @fst_aprod_addon1
                      ,[fst_aprod_tag2] = @fst_aprod_tag2
                      ,[fst_aprod_type2] = @fst_aprod_type2
                      ,[fst_aprod_base2] = @fst_aprod_base2
                      ,[fst_aprod_addon2] = @fst_aprod_addon2
                      ,[fst_aprod_tag3] = @fst_aprod_tag3
                      ,[fst_aprod_type3] = @fst_aprod_type3
                      ,[fst_aprod_base3] = @fst_aprod_base3
                      ,[fst_aprod_addon3] = @fst_aprod_addon3
                      ,[fst_aprod_tag4] = @fst_aprod_tag4
                      ,[fst_aprod_type4] = @fst_aprod_type4
                      ,[fst_aprod_base4] = @fst_aprod_base4
                      ,[fst_aprod_addon4] = @fst_aprod_addon4
                      ,[fst_aprod_tag5] = @fst_aprod_tag5
                      ,[fst_aprod_type5] = @fst_aprod_type5
                      ,[fst_aprod_base5] = @fst_aprod_base5
                      ,[fst_aprod_addon5] = @fst_aprod_addon5
                      ,[fst_prim_ssn] = @fst_prim_ssn
                      ,[fst_sec_ssn] = @fst_sec_ssn
                      ,[ral_apr] = @ral_apr
                      ,[ral_finance_chrg] = @ral_finance_chrg
                      ,[admin_tran_fee] = @admin_tran_fee
                      ,[cpts_ef_fee] = @cpts_ef_fee
                      ,[ero_ef_fee] = @ero_ef_fee
                      ,[admin_ef_fee] = @admin_ef_fee
                      ,[fst_cpts_ef_fee] = @fst_cpts_ef_fee
                      ,[fst_ero_ef_fee] = @fst_ero_ef_fee
                      ,[fst_admin_ef_fee] = @fst_admin_ef_fee
  WHERE pssn = @pssn
  IF @@ROWCOUNT = 0
    INSERT INTO [dbo].[tblLoanApp] ([pssn]
                           ,[bankapp_id]
                           --,[status]
                           --,[RejectCode]
                           --,[RejectDescription]
                           ,[user_id]
                           ,[user_spec]
                           ,[efin]
                           ,[master]
                           ,[site_id]
                           ,[pri_fname]
                           ,[pri_init]
                           ,[pri_lname]
                           ,[pri_dob]
                           ,[sec_ssn]
                           ,[sec_fname]
                           ,[sec_init]
                           ,[sec_lname]
                           ,[sec_dob]
                           ,[address]
                           ,[city]
                           ,[state]
                           ,[zip]
                           ,[res_address]
                           ,[res_city]
                           ,[res_state]
                           ,[res_zip]
                           ,[home_phone]
                           ,[work_phone]
                           ,[ral_flag]
                           ,[refund]
                           ,[bal_due]
                           ,[fld_1272]
                           ,[fld_1278]
                           ,[fld_1274]
                           ,[fld_1276]
                           ,[tot_income]
                           ,[tot_tax]
                           ,[tot_itw]
                           ,[tot_agi]
                           ,[tot_eic]
                           ,[tot_dep]
                           ,[fld_eicf]
                           ,[site_rej]
                           ,[verify_errors]
                           ,[import_errors]
                           ,[bank_id]
                           ,[pei_tran_fee]
                           ,[ero_tran_fee]
                           ,[sb_prep_fee]
                           ,[tax_prep_fee]
                           ,[ero_bank_fee]
                           ,[req_bank_fee]
                           ,[req_acnt_fee]
                           ,[pei_prot_fee]
                           ,[ero_prot_fee]
                           ,[req_tech_fee]
                           ,[req_loan_amt]
                           ,[verify_level]
                           ,[filing_stat]
                           ,[prep_ind]
                           ,[prep_id]
                           ,[cross_collect_ind]
                           ,[w2_ein]
                           ,[w2_cnt]
                           ,[ero_state]
                           ,[sig_date]
                           ,[all_state_rfnd]
                           ,[state_rac]
                           ,[pt_rtn]
                           ,[pt_dan]
                           ,[pt_acnt_type]
                           ,[cash_card]
                           ,[email_address]
                           ,[guid]
                           ,[rsrvd_ip_addr]
                           ,[irs_8453OL]
                           ,[verify_addr_ind]
                           ,[alt_addr_ind]
                           ,[alt_addr_descr]
                           ,[prim_1st_id_type]
                           ,[prim_1st_id_descr]
                           ,[prim_1st_id_nbr]
                           ,[prim_1st_id_place]
                           ,[prim_1st_id_issued]
                           ,[prim_1st_id_expire]
                           ,[prim_1st_id_info]
                           ,[prim_1st_id_dflag]
                           ,[prim_1st_id_dreas]
                           ,[prim_2nd_id_type]
                           ,[prim_2nd_id_descr]
                           ,[prim_2nd_id_nbr]
                           ,[prim_2nd_id_place]
                           ,[prim_2nd_id_issued]
                           ,[prim_2nd_id_expire]
                           ,[prim_2nd_id_dflag]
                           ,[prim_2nd_id_dreas]
                           ,[prim_3rd_id_type]
                           ,[prim_3rd_id_descr]
                           ,[prim_3rd_id_nbr]
                           ,[prim_3rd_id_place]
                           ,[prim_3rd_id_issued]
                           ,[prim_3rd_id_expire]
                           ,[prim_3rd_id_dflag]
                           ,[prim_3rd_id_dreas]
                           ,[sec_1st_id_type]
                           ,[sec_1st_id_descr]
                           ,[sec_1st_id_nbr]
                           ,[sec_1st_id_place]
                           ,[sec_1st_id_issued]
                           ,[sec_1st_id_expire]
                           ,[sec_1st_id_info]
                           ,[sec_1st_id_dflag]
                           ,[sec_1st_id_dreas]
                           ,[sec_2nd_id_type]
                           ,[sec_2nd_id_descr]
                           ,[sec_2nd_id_nbr]
                           ,[sec_2nd_id_place]
                           ,[sec_2nd_id_issued]
                           ,[sec_2nd_id_expire]
                           ,[sec_2nd_id_dflag]
                           ,[sec_2nd_id_dreas]
                           ,[sec_3rd_id_type]
                           ,[sec_3rd_id_descr]
                           ,[sec_3rd_id_nbr]
                           ,[sec_3rd_id_place]
                           ,[sec_3rd_id_issued]
                           ,[sec_3rd_id_expire]
                           ,[sec_3rd_id_dflag]
                           ,[sec_3rd_id_dreas]
                           ,[borr_ind]
                           ,[mil_ind]
                           ,[due_dil_ind]
                           ,[prot_plus]
                           ,[lexis_nexis]
                           ,[pref_contact]
                           ,[roll]
                           ,[ptin]
                           ,[esig_flag]
                           ,[dep_1_lname]
                           ,[dep_1_rel]
                           ,[dep_2_lname]
                           ,[dep_2_rel]
                           ,[dep_3_lname]
                           ,[dep_3_rel]
                           ,[dep_4_lname]
                           ,[dep_4_rel]
                           ,[wages]
                           ,[schc_incomeloss]
                           ,[other_gainloss]
                           ,[sche_incomeloss]
                           ,[farm_incomeloss]
                           ,[total_item_std_ded]
                           ,[child_tax_credit]
                           ,[edu_credit]
                           ,[est_tax_pay]
                           ,[occupation]
                           ,[eic_dep_1_lname]
                           ,[eic_dep_1_byear]
                           ,[eic_dep_1_rel]
                           ,[eic_dep_2_lname]
                           ,[eic_dep_2_byear]
                           ,[eic_dep_2_rel]
                           ,[eic_dep_3_lname]
                           ,[eic_dep_3_byear]
                           ,[eic_dep_3_rel]
                           ,[prim_secq]
                           ,[prim_seca]
                           ,[prim_lang]
                           ,[prim_contact_meth]
                           ,[prim_cell]
                           ,[prim_cell_carrier]
                           ,[prim_citizen]
                           ,[prim_citizen_country]
                           ,[sec_secq]
                           ,[sec_seca]
                           ,[sec_lang]
                           ,[sec_contact_meth]
                           ,[sec_cell]
                           ,[sec_cell_carrier]
                           ,[sec_citizen]
                           ,[sec_citizen_country]
                           ,[sec_email]
                           ,[fld_8836_ind]
                           ,[fld_8862_ind]
                           ,[sig_ver_user]
                           ,[sig_ver_disclose]
                           ,[sig_ver_bankapp]
                           ,[sig_ver_tila]
                           ,[advnt_sendsms]
                           ,[advnt_sendemail]
                           ,[disb_type]
                           ,[ext_pay_amt]
                           ,[fld_8379_ind]
                           ,[advnt_email_discl]
                           ,[req_rush_fee]
                           ,[req_phone_fee]
                           ,[split_disb_amt]
                           ,[ip_addr]
                           ,[insertDate]
                           ,[irs_acc_dt]
                           ,[irs_acc_cd]
                           ,[sub_date]
                           ,[resp_date]
                           ,[batch]
                           ,[elf_prep_fee]
                           ,[req_cadr_fee]
                           ,[doc_signer]
                           ,[doc_tp]
                           ,[doc_prep]
                           --,[bank_stat]
                           ,[adv_cmpid]
                           ,[adv_locid]
                           ,[adv_dstid]
                           ,[bnk_prim_id]
                           ,[bnk_sec_id]
                           ,[bnk_appid]
                           ,[form_type_1040]
                           ,[decline_code]
                           ,[submission_id]
                           ,[req_utip_fee]
                           ,[req_mmac_fee]
                           ,[req_mmip_fee]
                           ,[padp_flag]
                           ,[rf_loan_ind]
                           ,[doc_prep_fee]
                           ,[fst_bnk_print_dt]
                           ,[lst_bnk_print_dt]
                           ,[cust_id_sha1]
                           ,[rt_lite_ind]
                           ,[fst_req_bank_fee]
                           ,[fst_req_acnt_fee]
                           ,[fst_req_loan_amt]
                           ,[fst_tax_prep_fee]
                           ,[fst_pei_tran_fee]
                           ,[fst_ero_tran_fee]
                           ,[fst_sb_prep_fee]
                           ,[fst_pei_prot_fee]
                           ,[fst_ero_prot_fee]
                           ,[fst_req_tech_fee]
                           ,[fst_prod_type]
                           ,[lst_req_bank_fee]
                           ,[lst_req_acnt_fee]
                           ,[lst_req_loan_amt]
                           ,[lst_tax_prep_fee]
                           ,[lst_pei_tran_fee]
                           ,[lst_ero_tran_fee]
                           ,[lst_sb_prep_fee]
                           ,[lst_pei_prot_fee]
                           ,[lst_ero_prot_fee]
                           ,[lst_req_tech_fee]
                           ,[lst_prod_type]
                           ,[fst_aprod_tag1]
                           ,[fst_aprod_type1]
                           ,[fst_aprod_base1]
                           ,[fst_aprod_addon1]
                           ,[fst_aprod_tag2]
                           ,[fst_aprod_type2]
                           ,[fst_aprod_base2]
                           ,[fst_aprod_addon2]
                           ,[fst_aprod_tag3]
                           ,[fst_aprod_type3]
                           ,[fst_aprod_base3]
                           ,[fst_aprod_addon3]
                           ,[fst_aprod_tag4]
                           ,[fst_aprod_type4]
                           ,[fst_aprod_base4]
                           ,[fst_aprod_addon4]
                           ,[fst_aprod_tag5]
                           ,[fst_aprod_type5]
                           ,[fst_aprod_base5]
                           ,[fst_aprod_addon5]
                           ,[fst_prim_ssn]
                           ,[fst_sec_ssn]
                           ,[ral_apr]
                           ,[ral_finance_chrg]
                           ,[admin_tran_fee]
                           ,[cpts_ef_fee]
                           ,[ero_ef_fee]
                           ,[admin_ef_fee]
                           ,[fst_cpts_ef_fee]
                           ,[fst_ero_ef_fee]
                           ,[fst_admin_ef_fee]
  ) VALUES
                           (@pssn
                           ,@bankapp_id
                           --,@status
                           --,@rejectcode
                           --,@rejectdescription
                           ,@user_id
                           ,@user_spec
                           ,@efin
                           ,@master
                           ,@site_id
                           ,@pri_fname
                           ,@pri_init
                           ,@pri_lname
                           ,@pri_dob
                           ,@sec_ssn
                           ,@sec_fname
                           ,@sec_init
                           ,@sec_lname
                           ,@sec_dob
                           ,@address
                           ,@city
                           ,@state
                           ,@zip
                           ,@res_address
                           ,@res_city
                           ,@res_state
                           ,@res_zip
                           ,@home_phone
                           ,@work_phone
                           ,@ral_flag
                           ,@refund
                           ,@bal_due
                           ,@fld_1272
                           ,@fld_1278
                           ,@fld_1274
                           ,@fld_1276
                           ,@tot_income
                           ,@tot_tax
                           ,@tot_itw
                           ,@tot_agi
                           ,@tot_eic
                           ,@tot_dep
                           ,@fld_eicf
                           ,@site_rej
                           ,@verify_errors
                           ,@import_errors
                           ,@bank_id
                           ,@pei_tran_fee
                           ,@ero_tran_fee
                           ,@sb_prep_fee
                           ,@tax_prep_fee
                           ,@ero_bank_fee
                           ,@req_bank_fee
                           ,@req_acnt_fee
                           ,@pei_prot_fee
                           ,@ero_prot_fee
                           ,@req_tech_fee
                           ,@req_loan_amt
                           ,@verify_level
                           ,@filing_stat
                           ,@prep_ind
                           ,@prep_id
                           ,@cross_collect_ind
                           ,@w2_ein
                           ,@w2_cnt
                           ,@ero_state
                           ,@sig_date
                           ,@all_state_rfnd
                           ,@state_rac
                           ,@pt_rtn
                           ,@pt_dan
                           ,@pt_acnt_type
                           ,@cash_card
                           ,@email_address
                           ,@guid
                           ,@rsrvd_ip_addr
                           ,@irs_8453ol
                           ,@verify_addr_ind
                           ,@alt_addr_ind
                           ,@alt_addr_descr
                           ,@prim_1st_id_type
                           ,@prim_1st_id_descr
                           ,@prim_1st_id_nbr
                           ,@prim_1st_id_place
                           ,@prim_1st_id_issued
                           ,@prim_1st_id_expire
                           ,@prim_1st_id_info
                           ,@prim_1st_id_dflag
                           ,@prim_1st_id_dreas
                           ,@prim_2nd_id_type
                           ,@prim_2nd_id_descr
                           ,@prim_2nd_id_nbr
                           ,@prim_2nd_id_place
                           ,@prim_2nd_id_issued
                           ,@prim_2nd_id_expire
                           ,@prim_2nd_id_dflag
                           ,@prim_2nd_id_dreas
                           ,@prim_3rd_id_type
                           ,@prim_3rd_id_descr
                           ,@prim_3rd_id_nbr
                           ,@prim_3rd_id_place
                           ,@prim_3rd_id_issued
                           ,@prim_3rd_id_expire
                           ,@prim_3rd_id_dflag
                           ,@prim_3rd_id_dreas
                           ,@sec_1st_id_type
                           ,@sec_1st_id_descr
                           ,@sec_1st_id_nbr
                           ,@sec_1st_id_place
                           ,@sec_1st_id_issued
                           ,@sec_1st_id_expire
                           ,@sec_1st_id_info
                           ,@sec_1st_id_dflag
                           ,@sec_1st_id_dreas
                           ,@sec_2nd_id_type
                           ,@sec_2nd_id_descr
                           ,@sec_2nd_id_nbr
                           ,@sec_2nd_id_place
                           ,@sec_2nd_id_issued
                           ,@sec_2nd_id_expire
                           ,@sec_2nd_id_dflag
                           ,@sec_2nd_id_dreas
                           ,@sec_3rd_id_type
                           ,@sec_3rd_id_descr
                           ,@sec_3rd_id_nbr
                           ,@sec_3rd_id_place
                           ,@sec_3rd_id_issued
                           ,@sec_3rd_id_expire
                           ,@sec_3rd_id_dflag
                           ,@sec_3rd_id_dreas
                           ,@borr_ind
                           ,@mil_ind
                           ,@due_dil_ind
                           ,@prot_plus
                           ,@lexis_nexis
                           ,@pref_contact
                           ,@roll
                           ,@ptin
                           ,@esig_flag
                           ,@dep_1_lname
                           ,@dep_1_rel
                           ,@dep_2_lname
                           ,@dep_2_rel
                           ,@dep_3_lname
                           ,@dep_3_rel
                           ,@dep_4_lname
                           ,@dep_4_rel
                           ,@wages
                           ,@schc_incomeloss
                           ,@other_gainloss
                           ,@sche_incomeloss
                           ,@farm_incomeloss
                           ,@total_item_std_ded
                           ,@child_tax_credit
                           ,@edu_credit
                           ,@est_tax_pay
                           ,@occupation
                           ,@eic_dep_1_lname
                           ,@eic_dep_1_byear
                           ,@eic_dep_1_rel
                           ,@eic_dep_2_lname
                           ,@eic_dep_2_byear
                           ,@eic_dep_2_rel
                           ,@eic_dep_3_lname
                           ,@eic_dep_3_byear
                           ,@eic_dep_3_rel
                           ,@prim_secq
                           ,@prim_seca
                           ,@prim_lang
                           ,@prim_contact_meth
                           ,@prim_cell
                           ,@prim_cell_carrier
                           ,@prim_citizen
                           ,@prim_citizen_country
                           ,@sec_secq
                           ,@sec_seca
                           ,@sec_lang
                           ,@sec_contact_meth
                           ,@sec_cell
                           ,@sec_cell_carrier
                           ,@sec_citizen
                           ,@sec_citizen_country
                           ,@sec_email
                           ,@fld_8836_ind
                           ,@fld_8862_ind
                           ,@sig_ver_user
                           ,@sig_ver_disclose
                           ,@sig_ver_bankapp
                           ,@sig_ver_tila
                           ,@advnt_sendsms
                           ,@advnt_sendemail
                           ,@disb_type
                           ,@ext_pay_amt
                           ,@fld_8379_ind
                           ,@advnt_email_discl
                           ,@req_rush_fee
                           ,@req_phone_fee
                           ,@split_disb_amt
                           ,@ip_addr
                           ,@insertdate
                           ,@irs_acc_dt
                           ,@irs_acc_cd
                           ,@sub_date
                           ,@resp_date
                           ,@batch
                           ,@elf_prep_fee
                           ,@req_cadr_fee
                           ,@doc_signer
                           ,@doc_tp
                           ,@doc_prep
                           --,@bank_stat
                           ,@adv_cmpid
                           ,@adv_locid
                           ,@adv_dstid
                           ,@bnk_prim_id
                           ,@bnk_sec_id
                           ,@bnk_appid
                           ,@form_type_1040
                           ,@decline_code
                           ,@submission_id
                           ,@req_utip_fee
                           ,@req_mmac_fee
                           ,@req_mmip_fee
                           ,@padp_flag
                           ,@rf_loan_ind
                           ,@doc_prep_fee
                           ,@fst_bnk_print_dt
                           ,@lst_bnk_print_dt
                           ,@cust_id_sha1
                           ,@rt_lite_ind
                           ,@fst_req_bank_fee
                           ,@fst_req_acnt_fee
                           ,@fst_req_loan_amt
                           ,@fst_tax_prep_fee
                           ,@fst_pei_tran_fee
                           ,@fst_ero_tran_fee
                           ,@fst_sb_prep_fee
                           ,@fst_pei_prot_fee
                           ,@fst_ero_prot_fee
                           ,@fst_req_tech_fee
                           ,@fst_prod_type
                           ,@lst_req_bank_fee
                           ,@lst_req_acnt_fee
                           ,@lst_req_loan_amt
                           ,@lst_tax_prep_fee
                           ,@lst_pei_tran_fee
                           ,@lst_ero_tran_fee
                           ,@lst_sb_prep_fee
                           ,@lst_pei_prot_fee
                           ,@lst_ero_prot_fee
                           ,@lst_req_tech_fee
                           ,@lst_prod_type
                           ,@fst_aprod_tag1
                           ,@fst_aprod_type1
                           ,@fst_aprod_base1
                           ,@fst_aprod_addon1
                           ,@fst_aprod_tag2
                           ,@fst_aprod_type2
                           ,@fst_aprod_base2
                           ,@fst_aprod_addon2
                           ,@fst_aprod_tag3
                           ,@fst_aprod_type3
                           ,@fst_aprod_base3
                           ,@fst_aprod_addon3
                           ,@fst_aprod_tag4
                           ,@fst_aprod_type4
                           ,@fst_aprod_base4
                           ,@fst_aprod_addon4
                           ,@fst_aprod_tag5
                           ,@fst_aprod_type5
                           ,@fst_aprod_base5
                           ,@fst_aprod_addon5
                           ,@fst_prim_ssn
                           ,@fst_sec_ssn
                           ,@ral_apr
                           ,@ral_finance_chrg
                           ,@admin_tran_fee
                           ,@cpts_ef_fee
                           ,@ero_ef_fee
                           ,@admin_ef_fee
                           ,@fst_cpts_ef_fee
                           ,@fst_ero_ef_fee
                           ,@fst_admin_ef_fee
                           )






