
CREATE VIEW [dbo].[vwPriorYearTaxMast]
AS
SELECT     pssn, user_id, user_spec, archive_no, sb_id, sb_spec, fran_id, fran_spec, efin, master, site_id, prim_ctrl, pri_fname, pri_init, pri_lname, pri_dob, sec_ssn, sec_ctrl, 
                      sec_fname, sec_init, sec_lname, sec_dob, address, city, state, zip, res_address, res_city, res_state, res_zip, home_phone, work_phone, ral_flag, refund, bal_due, 
                      fld_1272, fld_1278, fld_1274, fld_1276, tot_income, tot_tax, tot_itw, tot_agi, tot_eic, tot_dep, fld_ero, fld_eicf, fld_1040, site_rej, stat_cnt, old_stat, ret_stat, txn_code, 
                      log_code, verify_errors, import_errors, fdate, ftime, ldate, ltime, postmark, submissionid, irs_ack_dt, irs_acc_cd, irs_eft_ind, irs_dup_code, rej_cnt, irs_refund, 
                      bank_id, sub_date, resp_date, bank_stat, decline_code, pei_tran_fee, ero_tran_fee, sb_prep_fee, tax_prep_fee, ero_bank_fee, elf_prep_fee, req_bank_fee, 
                      req_acnt_fee, pei_prot_fee, ero_prot_fee, req_tech_fee, req_loan_amt, verify_level, filing_stat, prep_ind, prep_id, cross_collect_ind, w2_ein, w2_cnt, ero_state, 
                      sig_date, tot_bank_fee, tot_acnt_fee, tot_prep_fee, ebnk_pay_date, ebnk_pay_amt, tot_tran_fee, tot_sb_fee, tot_pprot_fee, tot_eprot_fee, tot_tech_fee, tot_ebank_fee, 
                      tot_prior_yr_amt, ral_loan_amt, ral_finance_chrg, ral_financed_amt, ral_apr, fee_pay_date, fee_pay_amt, tran_pay_date, tran_pay_amt, tran_add_date, tran_add_amt, 
                      sb_pay_date, sb_pay_amt, irs_pay_date, irs_pay_amt, sta_pay_date1, sta_pay_amt1, sta_pay_date2, sta_pay_amt2, sta_pay_date3, sta_pay_amt3, otc_pay_date, 
                      otc_pay_amt, cancel_date, all_state_rfnd, state_rac, user_dcnx, xmit_date, xmit_time, xmit_arcv_no, xmit_refund, pt_rtn, pt_dan, pt_acnt_type, cash_card, 
                      irs_debt_ind, irs_dob_errs, toss_ackl, irs_pin_ind, irs_payment_ind, email_address, guid, rsrvd_ip_addr, irs_8453OL, verify_addr_ind, alt_addr_ind, alt_addr_descr, 
                      prim_1st_id_type, prim_1st_id_descr, prim_1st_id_nbr, prim_1st_id_place, prim_1st_id_issued, prim_1st_id_expire, prim_1st_id_info, prim_1st_id_dflag, 
                      prim_1st_id_dreas, prim_2nd_id_type, prim_2nd_id_descr, prim_2nd_id_nbr, prim_2nd_id_place, prim_2nd_id_issued, prim_2nd_id_expire, prim_2nd_id_dflag, 
                      prim_2nd_id_dreas, prim_3rd_id_type, prim_3rd_id_descr, prim_3rd_id_nbr, prim_3rd_id_place, prim_3rd_id_issued, prim_3rd_id_expire, prim_3rd_id_dflag, 
                      prim_3rd_id_dreas, sec_1st_id_type, sec_1st_id_descr, sec_1st_id_nbr, sec_1st_id_place, sec_1st_id_issued, sec_1st_id_expire, sec_1st_id_info, 
                      sec_1st_id_dflag, sec_1st_id_dreas, sec_2nd_id_type, sec_2nd_id_descr, sec_2nd_id_nbr, sec_2nd_id_place, sec_2nd_id_issued, sec_2nd_id_expire, 
                      sec_2nd_id_dflag, sec_2nd_id_dreas, sec_3rd_id_type, sec_3rd_id_descr, sec_3rd_id_nbr, sec_3rd_id_place, sec_3rd_id_issued, sec_3rd_id_expire, 
                      sec_3rd_id_dflag, sec_3rd_id_dreas, borr_ind, mil_ind, due_dil_ind, prot_plus, login_id, rtn_id, lexis_nexis, mef_eligible, ws_lock, time_stamp, pref_contact, roll, 
                      mef_errcnt, ptin, esig_flag, dep_1_lname, dep_1_rel, dep_2_lname, dep_2_rel, dep_3_lname, dep_3_rel, dep_4_lname, dep_4_rel, wages, schc_incomeloss, 
                      other_gainloss, sche_incomeloss, farm_incomeloss, total_item_std_ded, child_tax_credit, edu_credit, est_tax_pay, occupation, eic_dep_1_lname, eic_dep_1_byear, 
                      eic_dep_1_rel, eic_dep_2_lname, eic_dep_2_byear, eic_dep_2_rel, eic_dep_3_lname, eic_dep_3_byear, eic_dep_3_rel, prim_secq, prim_seca, prim_lang, 
                      prim_contact_meth, prim_cell, prim_cell_carrier, prim_citizen, prim_citizen_country, sec_secq, sec_seca, sec_lang, sec_contact_meth, sec_cell, sec_cell_carrier, 
                      sec_citizen, sec_citizen_country, sec_email, fld_8836_ind, fld_8862_ind, adv_cmpid, adv_locid, adv_dstid, bnk_appid, bnk_prim_id, bnk_sec_id, sig_ver_user, 
                      sig_ver_disclose, sig_ver_bankapp, sig_ver_tila, fst_req_bank_fee, fst_req_acnt_fee, fst_req_loan_amt, fst_financed_amt, fst_ral_apr, fst_tax_prep_fee, 
                      fst_pei_tran_fee, fst_ero_tran_fee, fst_sb_prep_fee, fst_pei_prot_fee, fst_ero_prot_fee, fst_req_tech_fee, fst_bnk_print_dt, fst_bnk_print_time, fst_prod_type, 
                      fst_borr_ind, lst_req_bank_fee, lst_req_acnt_fee, lst_req_loan_amt, lst_financed_amt, lst_ral_apr, lst_tax_prep_fee, lst_pei_tran_fee, lst_ero_tran_fee, 
                      lst_sb_prep_fee, lst_pei_prot_fee, lst_ero_prot_fee, lst_req_tech_fee, lst_bnk_print_dt, lst_bnk_print_time, lst_prod_type, lst_borr_ind, advnt_sendsms, 
                      advnt_sendemail, rbt_sendsms, form_type_1040, rbt_taxinfo_release, py_refund, py_irs_pay_amt, roll_fee_pay_amt, roll_tran_pay_amt, roll_sb_pay_amt, 
                      schema_version, cust_id_sha1, ip_address, disb_type, ext_pay_amt, fld_8379_ind, fetchSeq, advnt_email_discl, req_rush_fee, tot_rush_fee, req_phone_fee, 
                      tot_phone_fee, tot_prev_paid_amt, recTS, fyear, lyear, irs_ack_yr, xmit_year, split_disb_amt, mefhold
FROM         dbCrosslink13.dbo.tblTaxmast



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tblTaxmast (dbCrosslink12.dbo)"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 226
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwPriorYearTaxMast';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vwPriorYearTaxMast';

