CREATE TABLE [dbo].[tblXlinkOfficeSetup] (
    [officeSetup_id]                    INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [user_id]                           INT            CONSTRAINT [DF_tblXlinkOfficeSetup_user_id] DEFAULT ('') NULL,
    [account_id]                        VARCHAR (8)    CONSTRAINT [DF_tblXlinkOfficeSetup_account_id] DEFAULT ('') NULL,
    [create_date]                       DATETIME       CONSTRAINT [DF_tblXlinkOfficeSetup_create_date] DEFAULT (getdate()) NULL,
    [edit_date]                         DATETIME       CONSTRAINT [DF_tblXlinkOfficeSetup_edit_date] DEFAULT (getdate()) NULL,
    [publish_date]                      DATETIME       NULL,
    [name]                              VARCHAR (40)   CONSTRAINT [DF_tblXlinkOfficeSetup_name] DEFAULT ('') NULL,
    [location]                          VARCHAR (40)   CONSTRAINT [DF_tblXlinkOfficeSetup_location] DEFAULT ('') NULL,
    [phone]                             VARCHAR (10)   CONSTRAINT [DF_tblXlinkOfficeSetup_phone] DEFAULT ('') NULL,
    [fax]                               VARCHAR (10)   CONSTRAINT [DF_tblXlinkOfficeSetup_fax] DEFAULT ('') NULL,
    [email]                             VARCHAR (75)   CONSTRAINT [DF_tblXlinkOfficeSetup_email] DEFAULT ('') NULL,
    [transmit_type]                     CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_transmit_type] DEFAULT ('') NULL,
    [transfer_pdf]                      CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_transfer_pdf] DEFAULT ('') NULL,
    [transfer_invoice]                  CHAR (1)       NULL,
    [transfer_incomplete]               CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_transfer_incomplete] DEFAULT ('') NULL,
    [transfer_complete]                 CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_transfer_complete] DEFAULT ('') NULL,
    [receipt_required]                  CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_receipt_required] DEFAULT ('') NULL,
    [receipt_auto]                      CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_receipt_auto] DEFAULT ('') NULL,
    [range1begin]                       VARCHAR (5)    CONSTRAINT [DF_tblXlinkOfficeSetup_range1begin] DEFAULT ('') NULL,
    [range1end]                         VARCHAR (5)    CONSTRAINT [DF_tblXlinkOfficeSetup_range1end] DEFAULT ('') NULL,
    [range2begin]                       VARCHAR (5)    CONSTRAINT [DF_tblXlinkOfficeSetup_range2begin] DEFAULT ('') NULL,
    [range2end]                         VARCHAR (5)    CONSTRAINT [DF_tblXlinkOfficeSetup_range2end] DEFAULT ('') NULL,
    [prevent_transmit]                  CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_prevent_transmit] DEFAULT ('') NULL,
    [warning_errors]                    CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_warning_errors] DEFAULT ('') NULL,
    [override_errors]                   CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_override_errors] DEFAULT ('') NULL,
    [default_efin]                      CHAR (6)       CONSTRAINT [DF_tblXlinkOfficeSetup_default_efin] DEFAULT ('') NULL,
    [dcn_new_efins]                     VARCHAR (9)    CONSTRAINT [DF_tblXlinkOfficeSetup_dcn_new_efins] DEFAULT ('') NULL,
    [teletax_number]                    VARCHAR (14)   CONSTRAINT [DF_tblXlinkOfficeSetup_teletax_number] DEFAULT ('') NULL,
    [default_sbin]                      VARCHAR (6)    CONSTRAINT [DF_tblXlinkOfficeSetup_default_sbin] DEFAULT ('') NULL,
    [assign_dcn_locally]                CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_assign_dcn_locally] DEFAULT ('') NULL,
    [discard_ack]                       CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_discard_ack] DEFAULT ('') NULL,
    [auto_pins]                         CHAR (1)       NULL,
    [leave_acknowledged]                CHAR (1)       NULL,
    [state_prompt]                      CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_state_prompt] DEFAULT ('') NULL,
    [company_name]                      VARCHAR (40)   CONSTRAINT [DF_tblXlinkOfficeSetup_company_name] DEFAULT ('') NULL,
    [ein]                               CHAR (9)       CONSTRAINT [DF_tblXlinkOfficeSetup_ein] DEFAULT ('') NULL,
    [company_address]                   VARCHAR (40)   CONSTRAINT [DF_tblXlinkOfficeSetup_company_address] DEFAULT ('') NULL,
    [company_city]                      VARCHAR (20)   CONSTRAINT [DF_tblXlinkOfficeSetup_company_city] DEFAULT ('') NULL,
    [company_state]                     CHAR (2)       CONSTRAINT [DF_tblXlinkOfficeSetup_company_state] DEFAULT ('') NULL,
    [company_zip]                       CHAR (5)       CONSTRAINT [DF_tblXlinkOfficeSetup_company_zip] DEFAULT ('') NULL,
    [self_employed]                     CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_self_employed] DEFAULT ('') NULL,
    [eros_name]                         VARCHAR (40)   CONSTRAINT [DF_tblXlinkOfficeSetup_eros_name] DEFAULT ('') NULL,
    [eros_ein]                          CHAR (9)       CONSTRAINT [DF_tblXlinkOfficeSetup_eros_ein] DEFAULT ('') NULL,
    [firm_address]                      VARCHAR (40)   CONSTRAINT [DF_tblXlinkOfficeSetup_firm_address] DEFAULT ('') NULL,
    [firm_city]                         VARCHAR (20)   CONSTRAINT [DF_tblXlinkOfficeSetup_firm_city] DEFAULT ('') NULL,
    [firm_state]                        CHAR (2)       CONSTRAINT [DF_tblXlinkOfficeSetup_firm_state] DEFAULT ('') NULL,
    [firm_zip]                          CHAR (5)       CONSTRAINT [DF_tblXlinkOfficeSetup_firm_zip] DEFAULT ('') NULL,
    [ero_self_employed]                 CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_ero_self_employed] DEFAULT ('') NULL,
    [ero_sbin]                          VARCHAR (6)    CONSTRAINT [DF_tblXlinkOfficeSetup_ero_sbin] DEFAULT ('') NULL,
    [site_id_default]                   VARCHAR (10)   CONSTRAINT [DF_tblXlinkOfficeSetup_site_id_default] DEFAULT ('') NULL,
    [site_id_required]                  CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_site_id_required] DEFAULT ('') NULL,
    [auto_add_state_return]             CHAR (1)       NULL,
    [auto_add_state]                    CHAR (2)       NULL,
    [default_taxpayers_phone]           CHAR (1)       NULL,
    [allow_only_full_1040]              CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_allow_only_full_1040] DEFAULT ('') NULL,
    [require_prep_fee]                  CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_require_prep_fee] DEFAULT ('') NULL,
    [auto_lock_returns]                 CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_auto_lock_returns] DEFAULT ('') NULL,
    [auto_add_options]                  CHAR (1)       NULL,
    [hide_work_in_progress]             CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_hide_work_in_progress] DEFAULT ('') NULL,
    [jump_cursor_past_city]             CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_jump_cursor_past_city] DEFAULT ('') NULL,
    [windows_login_name]                CHAR (1)       NULL,
    [default_state_rac]                 CHAR (1)       NULL,
    [make_finished_read_only]           CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_make_finished_read_only] DEFAULT ('') NULL,
    [font_set]                          VARCHAR (1)    CONSTRAINT [DF_tblXlinkOfficeSetup_font_set] DEFAULT ((0)) NULL,
    [prior_yr_path]                     VARCHAR (30)   CONSTRAINT [DF_tblXlinkOfficeSetup_prior_yr_path] DEFAULT ('') NULL,
    [retrieval_path]                    VARCHAR (30)   CONSTRAINT [DF_tblXlinkOfficeSetup_retrieval_path] DEFAULT ('') NULL,
    [transfer_path]                     VARCHAR (30)   CONSTRAINT [DF_tblXlinkOfficeSetup_transfer_path] DEFAULT ('') NULL,
    [enable_backup]                     CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_enable_backup] DEFAULT ('') NULL,
    [backup_path]                       VARCHAR (30)   CONSTRAINT [DF_tblXlinkOfficeSetup_backup_path] DEFAULT ('') NULL,
    [billing_scheme]                    INT            CONSTRAINT [DF_tblXlinkOfficeSetup_billing_scheme] DEFAULT ('') NULL,
    [relationship_1]                    CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_relationship_1] DEFAULT ('') NULL,
    [age_1]                             CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_age_1] DEFAULT ('') NULL,
    [age_2]                             CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_age_2] DEFAULT ('') NULL,
    [resident_1]                        CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_resident_1] DEFAULT ('') NULL,
    [other_1]                           CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_other_1] DEFAULT ('') NULL,
    [other_2]                           CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_other_2] DEFAULT ('') NULL,
    [other_3]                           CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_other_3] DEFAULT ('') NULL,
    [other_4]                           CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_other_4] DEFAULT ('') NULL,
    [other_5]                           CHAR (1)       NULL,
    [other_6]                           CHAR (1)       NULL,
    [household_1]                       CHAR (1)       NULL,
    [household_2]                       CHAR (1)       NULL,
    [household_3]                       CHAR (1)       NULL,
    [support_1]                         CHAR (1)       NULL,
    [support_2]                         CHAR (1)       NULL,
    [status_1]                          CHAR (1)       NULL,
    [cash_contributions]                CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_cash_contributions] DEFAULT ('') NULL,
    [noncash_contributions_1]           CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_noncash_contributions_1] DEFAULT ('') NULL,
    [noncash_contributions_2]           CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_noncash_contributions_2] DEFAULT ('') NULL,
    [noncash_contributions_3]           CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_noncash_contributions_3] DEFAULT ('') NULL,
    [noncash_contributions_4]           CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_noncash_contributions_4] DEFAULT ('') NULL,
    [all_donations]                     CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_all_donations] DEFAULT ('') NULL,
    [donations_agi]                     INT            CONSTRAINT [DF_tblXlinkOfficeSetup_donations_agi] DEFAULT ('') NULL,
    [unreimbursed_expenses]             CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_unreimbursed_expenses] DEFAULT ('') NULL,
    [unreimbursed_agi]                  INT            CONSTRAINT [DF_tblXlinkOfficeSetup_unreimbursed_agi] DEFAULT ('') NULL,
    [deductions_1]                      CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_deductions_1] DEFAULT ('') NULL,
    [deductions_agi_1]                  INT            CONSTRAINT [DF_tblXlinkOfficeSetup_deductions_agi_1] DEFAULT ('') NULL,
    [deductions_2]                      CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_deductions_2] DEFAULT ('') NULL,
    [deductions_agi_2]                  INT            CONSTRAINT [DF_tblXlinkOfficeSetup_deductions_agi_2] DEFAULT ('') NULL,
    [describe_docs]                     CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_describe_docs] DEFAULT ('') NULL,
    [review_returns]                    CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_review_returns] DEFAULT ('') NULL,
    [not_purchased_from_relation]       CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_not_purchased_from_relation] DEFAULT ('') NULL,
    [not_purchased_with_bond]           CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_not_purchased_with_bond] DEFAULT ('') NULL,
    [not_received_as_gift]              CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_not_received_as_gift] DEFAULT ('') NULL,
    [describe_forms]                    CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_describe_forms] DEFAULT ('') NULL,
    [verify_proof]                      CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_verify_proof] DEFAULT ('') NULL,
    [verify_cobra]                      CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_verify_cobra] DEFAULT ('') NULL,
    [form_8880]                         CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_form_8880] DEFAULT ('') NULL,
    [verify_ss]                         CHAR (1)       CONSTRAINT [DF_tblXlinkOfficeSetup_verify_ss] DEFAULT ('') NULL,
    [ss_age]                            INT            CONSTRAINT [DF_tblXlinkOfficeSetup_ss_age] DEFAULT ('') NULL,
    [google_mail]                       VARCHAR (40)   CONSTRAINT [DF_tblXlinkOfficeSetup_google_mail] DEFAULT ('') NULL,
    [google_password]                   VARCHAR (40)   CONSTRAINT [DF_tblXlinkOfficeSetup_google_password] DEFAULT ('') NULL,
    [cross_collection]                  CHAR (1)       NULL,
    [double_entry_validation]           CHAR (1)       NULL,
    [year_to_year_exclude]              CHAR (1)       NULL,
    [child_care_expenses_1]             CHAR (1)       NULL,
    [child_care_expenses_2]             CHAR (1)       NULL,
    [auto_attach_income_and_info]       CHAR (1)       NULL,
    [turn_on_income_and_info]           CHAR (1)       NULL,
    [smtp_server]                       VARCHAR (40)   NULL,
    [smtp_server_port]                  INT            NULL,
    [franchiseuser_id]                  INT            NULL,
    [extended_duty]                     CHAR (1)       NULL,
    [referral_required]                 CHAR (1)       NULL,
    [appointment_firm_name]             VARCHAR (34)   NULL,
    [appointment_firm_address]          VARCHAR (34)   NULL,
    [appointment_firm_city]             VARCHAR (20)   NULL,
    [appointment_firm_state]            CHAR (2)       NULL,
    [appointment_firm_zip]              CHAR (9)       NULL,
    [appointment_firm_phone]            VARCHAR (10)   NULL,
    [eic_valid_business]                INT            NULL,
    [eic_business_expense]              INT            NULL,
    [eic_no_expenses]                   INT            NULL,
    [hoh_earned_income]                 INT            NULL,
    [print_final]                       CHAR (1)       NULL,
    [print_prepname_1040]               CHAR (1)       NULL,
    [auto_add_state_return_w2]          CHAR (1)       NULL,
    [add_print_settings]                BIT            NULL,
    [prn_adjustment]                    INT            NULL,
    [prn_remote_printing]               CHAR (1)       NULL,
    [prn_tax_estimation_copies]         INT            NULL,
    [prn_ef_declaration_copies]         INT            NULL,
    [prn_bank_app_copies]               INT            NULL,
    [prn_privacy_letter_copies]         INT            NULL,
    [prn_client_data_screen]            CHAR (1)       NULL,
    [prn_bank_fee_estimate_prep]        CHAR (1)       NULL,
    [prn_bank_fee_estimate_cli]         CHAR (1)       NULL,
    [prn_filing_options_prep]           CHAR (1)       NULL,
    [prn_filing_options_cli]            CHAR (1)       NULL,
    [prn_client_letter_prep]            CHAR (1)       NULL,
    [prn_client_letter_cli]             CHAR (1)       NULL,
    [prn_diagnostics]                   CHAR (1)       NULL,
    [prn_invoice_prep]                  CHAR (1)       NULL,
    [prn_invoice_cli]                   CHAR (1)       NULL,
    [prn_tax_comparision_prep]          CHAR (1)       NULL,
    [prn_tax_comparision_cli]           CHAR (1)       NULL,
    [prn_tax_summary_prep]              CHAR (1)       NULL,
    [prn_tax_summary_cli]               CHAR (1)       NULL,
    [prn_income_summary_prep]           CHAR (1)       NULL,
    [prn_income_summary_cli]            CHAR (1)       NULL,
    [prn_fed_return_prep]               CHAR (1)       NULL,
    [prn_fed_return_cli]                CHAR (1)       NULL,
    [prn_state_return_prep]             CHAR (1)       NULL,
    [prn_state_return_cli]              CHAR (1)       NULL,
    [prn_asset_detail_prep]             CHAR (1)       NULL,
    [prn_asset_detail_cli]              CHAR (1)       NULL,
    [prn_asset_detail_fed]              CHAR (1)       NULL,
    [prn_asset_detail_state]            CHAR (1)       NULL,
    [prn_worksheets_prep]               CHAR (1)       NULL,
    [prn_worksheets_cli]                CHAR (1)       NULL,
    [prn_worksheets_fed]                CHAR (1)       NULL,
    [prn_worksheets_state]              CHAR (1)       NULL,
    [prn_overflow_details_prep]         CHAR (1)       NULL,
    [prn_overflow_details_cli]          CHAR (1)       NULL,
    [prn_privacy_letter_prep]           CHAR (1)       NULL,
    [prn_privacy_letter_cli]            CHAR (1)       NULL,
    [prn_appointments_letter_prep]      CHAR (1)       NULL,
    [prn_appointments_letter_cli]       CHAR (1)       NULL,
    [prn_consent_form_prep]             CHAR (1)       NULL,
    [prn_consent_form_cli]              CHAR (1)       NULL,
    [prn_watermark]                     CHAR (1)       NULL,
    [prn_send_to_printer_prep]          CHAR (1)       NULL,
    [prn_send_to_printer_cli]           CHAR (1)       NULL,
    [prn_send_to_printer_efile]         CHAR (1)       NULL,
    [prn_send_to_printer_fed]           CHAR (1)       NULL,
    [prn_send_to_printer_state]         CHAR (1)       NULL,
    [prn_send_to_archive_prep]          CHAR (1)       NULL,
    [prn_send_to_archive_cli]           CHAR (1)       NULL,
    [prn_send_to_archive_efile]         CHAR (1)       NULL,
    [prn_send_to_archive_fed]           CHAR (1)       NULL,
    [prn_send_to_archive_state]         CHAR (1)       NULL,
    [prn_asset_detail]                  CHAR (1)       NULL,
    [prn_overflow_details]              CHAR (1)       NULL,
    [prn_always_print_signed]           CHAR (1)       NULL,
    [prn_preparer_copy_bank_app]        CHAR (1)       NULL,
    [prn_turn_off_esig]                 CHAR (1)       NULL,
    [prn_print_worksheets]              CHAR (1)       NULL,
    [prn_print_single_copy]             CHAR (1)       NULL,
    [prn_print_page_numbers]            CHAR (1)       NULL,
    [prn_print_payment_voucher]         CHAR (1)       NULL,
    [prn_print_site_id]                 CHAR (1)       NULL,
    [prn_print_bold]                    CHAR (1)       NULL,
    [prn_print_separation]              CHAR (1)       NULL,
    [prn_no_print_invoice_due]          CHAR (1)       NULL,
    [prn_print_tax_summary]             CHAR (1)       NULL,
    [prn_exit_on_print_final]           CHAR (1)       NULL,
    [prn_signature_block]               CHAR (1)       NULL,
    [prn_print_8879]                    CHAR (1)       NULL,
    [prn_turn_on_ssn_mask]              CHAR (1)       NULL,
    [prn_do_not_print_itemized_billing] CHAR (1)       NULL,
    [prn_8879_last_verify]              CHAR (1)       NULL,
    [prn_do_not_print_page2]            CHAR (1)       NULL,
    [include_info_text_message]         CHAR (1)       NULL,
    [print_activities]                  CHAR (1)       NULL,
    [box_15]                            CHAR (1)       NULL,
    [box_17]                            CHAR (1)       NULL,
    [override_print_settings]           BIT            NULL,
    [savers_credit]                     CHAR (1)       NULL,
    [verify_unemployment]               CHAR (1)       NULL,
    [un_age]                            INT            NULL,
    [verify_hh_status]                  CHAR (1)       NULL,
    [prior_year_state]                  CHAR (1)       NULL,
    [first_time_home]                   CHAR (1)       NULL,
    [year_to_year_exclude_docs]         CHAR (1)       NULL,
    [bus_billing_scheme]                INT            NULL,
    [prnbus_client_data_screen]         CHAR (1)       NULL,
    [prnbus_client_letter_prep]         CHAR (1)       NULL,
    [prnbus_client_letter_cli]          CHAR (1)       NULL,
    [prnbus_k1_letter_prep]             CHAR (1)       NULL,
    [prnbus_k1_letter_cli]              CHAR (1)       NULL,
    [prnbus_diagnostics]                CHAR (1)       NULL,
    [prnbus_invoice_prep]               CHAR (1)       NULL,
    [prnbus_invoice_cli]                CHAR (1)       NULL,
    [prnbus_fed_return_prep]            CHAR (1)       NULL,
    [prnbus_fed_return_cli]             CHAR (1)       NULL,
    [prnbus_state_return_prep]          CHAR (1)       NULL,
    [prnbus_state_return_cli]           CHAR (1)       NULL,
    [prnbus_asset_detail_prep]          CHAR (1)       NULL,
    [prnbus_asset_detail_cli]           CHAR (1)       NULL,
    [prnbus_asset_detail_fed]           CHAR (1)       NULL,
    [prnbus_asset_detail_state]         CHAR (1)       NULL,
    [prnbus_worksheets_prep]            CHAR (1)       NULL,
    [prnbus_worksheets_cli]             CHAR (1)       NULL,
    [prnbus_worksheets_fed]             CHAR (1)       NULL,
    [prnbus_worksheets_state]           CHAR (1)       NULL,
    [prnbus_overflow_details_prep]      CHAR (1)       NULL,
    [prnbus_overflow_details_cli]       CHAR (1)       NULL,
    [prnbus_privacy_letter_prep]        CHAR (1)       NULL,
    [prnbus_privacy_letter_cli]         CHAR (1)       NULL,
    [prnbus_watermark]                  CHAR (1)       NULL,
    [prnbus_send_to_printer_prep]       CHAR (1)       NULL,
    [prnbus_send_to_printer_cli]        CHAR (1)       NULL,
    [prnbus_send_to_printer_efile]      CHAR (1)       NULL,
    [prnbus_send_to_printer_fed]        CHAR (1)       NULL,
    [prnbus_send_to_printer_state]      CHAR (1)       NULL,
    [prnbus_send_to_archive_prep]       CHAR (1)       NULL,
    [prnbus_send_to_archive_cli]        CHAR (1)       NULL,
    [prnbus_send_to_archive_efile]      CHAR (1)       NULL,
    [prnbus_send_to_archive_fed]        CHAR (1)       NULL,
    [prnbus_send_to_archive_state]      CHAR (1)       NULL,
    [box_15a]                           CHAR (1)       NULL,
    [prn_referral_coupons]              CHAR (1)       NULL,
    [auto_save_mins]                    INT            NULL,
    [gmtc_disable]                      CHAR (1)       NULL,
    [silent_save]                       CHAR (1)       NULL,
    [no_drugs]                          CHAR (1)       NULL,
    [not_graduate]                      CHAR (1)       NULL,
    [student_age]                       CHAR (1)       NULL,
    [student_under_age]                 VARCHAR (2)    NULL,
    [student_over_age]                  VARCHAR (2)    NULL,
    [qualified_institution]             CHAR (1)       NULL,
    [student_1098t]                     CHAR (1)       NULL,
    [student_half_time]                 CHAR (1)       NULL,
    [student_claimed_credit]            CHAR (1)       NULL,
    [missing_deductions]                CHAR (1)       NULL,
    [company_phone]                     VARCHAR (10)   NULL,
    [prn_scriptel]                      VARCHAR (1)    NULL,
    [relationship_2]                    CHAR (1)       NULL,
    [real_estate_taxes]                 CHAR (1)       NULL,
    [mortgage_interest]                 CHAR (1)       NULL,
    [prn_disable_signatures]            CHAR (1)       NULL,
    [prn_opt_out_return_transfer]       CHAR (1)       NULL,
    [require_user_status]               CHAR (1)       NULL,
    [yty_include_preparer]              CHAR (1)       NULL,
    [shrink_verify]                     CHAR (1)       NULL,
    [prn_exclude_privacy]               CHAR (1)       NULL,
    [prn_inv_8879_8453]                 CHAR (1)       NULL,
    [prn_turn_on_ptin_mask]             CHAR (1)       NULL,
    [prn_state_client_letter_prep]      CHAR (1)       NULL,
    [prn_state_client_letter_cli]       CHAR (1)       NULL,
    [prn_state_asset_detail_prep]       CHAR (1)       NULL,
    [prn_state_asset_detail_cli]        CHAR (1)       NULL,
    [prnbus_state_client_letter_prep]   CHAR (1)       NULL,
    [prnbus_state_client_letter_cli]    CHAR (1)       NULL,
    [prnbus_financial_statement_prep]   CHAR (1)       NULL,
    [prnbus_financial_statement_cli]    CHAR (1)       NULL,
    [hoh_filing_status]                 CHAR (1)       NULL,
    [mortgage_interest_exceeds]         CHAR (1)       NULL,
    [mortgage_interest_exceeds_2]       INT            NULL,
    [require_third_party]               CHAR (1)       NULL,
    [disable_rt_lite]                   CHAR (1)       NULL,
    [blind_entry]                       CHAR (1)       NULL,
    [use_windows_hotkeys]               CHAR (1)       NULL,
    [prn_signature_block2]              CHAR (1)       NULL,
    [prn_date_pg2]                      CHAR (1)       NULL,
    [eic_schedc_loss]                   CHAR (1)       NULL,
    [eic_schedc_loss_expenses]          INT            NULL,
    [verify_refund_amounts_over]        CHAR (1)       NULL,
    [verify_refund_amount]              INT            NULL,
    [prn_coupon_amount]                 MONEY          NULL,
    [prn_no_pay_voucher8879]            CHAR (1)       NULL,
    [prn_coupon_expire]                 VARCHAR (30)   NULL,
    [prn_payment_voucher_prep]          CHAR (1)       NULL,
    [prn_payment_voucher_cli]           CHAR (1)       NULL,
    [bypass_key_tracking]               CHAR (1)       NULL,
    [verify_self_prepared]              CHAR (1)       NULL,
    [form_RRB_1099]                     CHAR (1)       NULL,
    [prn_send_to_email_prep]            CHAR (1)       NULL,
    [prn_send_to_email_cli]             CHAR (1)       NULL,
    [prn_send_to_email_efile]           CHAR (1)       NULL,
    [prn_send_to_email_fed]             CHAR (1)       NULL,
    [prn_send_to_email_state]           CHAR (1)       NULL,
    [prnbus_send_to_email_prep]         CHAR (1)       NULL,
    [prnbus_send_to_email_cli]          CHAR (1)       NULL,
    [prnbus_send_to_email_efile]        CHAR (1)       NULL,
    [prnbus_send_to_email_fed]          CHAR (1)       NULL,
    [prnbus_send_to_email_state]        CHAR (1)       NULL,
    [prn_ein_masking]                   CHAR (1)       NULL,
    [mask_ssn_ein]                      CHAR (1)       NULL,
    [disable_eic_checklist]             CHAR (1)       NULL,
    [leave_acknowledged_nbp]            CHAR (1)       NULL,
    [turn_on_acct_masking]              CHAR (1)       NULL,
    [require_cell_carrier]              CHAR (1)       NULL,
    [do_not_print_1040ES]               CHAR (1)       NULL,
    [auto_add_1040es]                   CHAR (1)       NULL,
    [auto_add_1040es_2]                 INT            NULL,
    [prn_8453_prep]                     CHAR (1)       NULL,
    [part_ira_nondeductable]            CHAR (1)       NULL,
    [verify_name_change]                CHAR (1)       NULL,
    [verify_itin]                       CHAR (1)       NULL,
    [require_signature_print_date]      CHAR (1)       NULL,
    [include_bank_info]                 CHAR (1)       NULL,
    [require_EF_PMT]                    CHAR (1)       NULL,
    [auto_add_schedules]                CHAR (1)       NULL,
    [print_bank_docs_with_final]        CHAR (1)       NULL,
    [consent_to_use_signed]             CHAR (1)       NULL,
    [auto_add_state_return_bus]         CHAR (1)       NULL,
    [auto_add_state_bus]                CHAR (2)       NULL,
    [ssa_1099_medicare]                 CHAR (1)       NULL,
    [ssa_1099_medicare_percent]         INT            NULL,
    [disable_auto_state]                CHAR (1)       NULL,
    [verify_yty_address]                CHAR (1)       NULL,
    [verify_ip_pin]                     CHAR (1)       NULL,
    [prn_fed_aca_letter_prep]           CHAR (1)       NULL,
    [prn_fed_aca_letter_cli]            CHAR (1)       NULL,
    [prn_bank_app_prep]                 CHAR (1)       NULL,
    [prn_bank_app_cli]                  CHAR (1)       NULL,
    [require_cell_phone]                CHAR (1)       NULL,
    [require_email_address]             CHAR (1)       NULL,
    [interview_forms_tree_color]        CHAR (1)       NULL,
    [custom_url1_title]                 VARCHAR (18)   NULL,
    [custom_url1]                       VARCHAR (80)   NULL,
    [custom_url2_title]                 VARCHAR (18)   NULL,
    [custom_url2]                       VARCHAR (80)   NULL,
    [custom_url3_title]                 VARCHAR (18)   NULL,
    [custom_url3]                       VARCHAR (80)   NULL,
    [disable_auto_state_bus]            CHAR (1)       NULL,
    [show_transmit_queue]               CHAR (1)       NULL,
    [credit_disallowance]               CHAR (1)       NULL,
    [prn_8453_cli]                      CHAR (1)       NULL,
    [auto_add_verify]                   CHAR (1)       NULL,
    [enable_due_diligence]              CHAR (1)       NULL,
    [prn_engagement_letter_prep]        CHAR (1)       NULL,
    [prn_engagement_letter_cli]         CHAR (1)       NULL,
    [prnbus_engagement_letter_prep]     CHAR (1)       NULL,
    [prnbus_engagement_letter_cli]      CHAR (1)       NULL,
    [print_order]                       VARCHAR (2048) NULL,
    [verify_prior_year]                 CHAR (1)       NULL,
    [verify_7202]                       CHAR (1)       NULL,
    [validate_covid19]                  CHAR (1)       NULL,
    [verify_cash_donations]             CHAR (1)       NULL,
    CONSTRAINT [PK_tblXlinkOfficeSetup] PRIMARY KEY CLUSTERED ([officeSetup_id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UN_user_id]
    ON [dbo].[tblXlinkOfficeSetup]([user_id] ASC) WITH (ALLOW_PAGE_LOCKS = OFF);

