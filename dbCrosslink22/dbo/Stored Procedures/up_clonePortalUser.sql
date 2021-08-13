CREATE procedure [dbo].[up_clonePortalUser]
    @sUserId            int
,   @tUserId            int

as

declare @fran table(
	parentId				int
,	childId					int
)

declare @fcount             int
declare @badUsers			bit
declare @errstr             nvarchar(2048)
declare @result             xml

    set nocount on

    -- bail if the source user id is the same as the target user id   
    if @sUserId = @tUserId
        begin
            set @errstr = 'The source UserId (' + convert(varchar(25),@sUserId) + ') and the target UserId (' +  convert(varchar(25),@tUserId) + ') are the same.'  
            raiserror(@errstr,11,1)                   
            return          
        end

    -- Check for the users being in the same franchise teir, or not at all.
	insert @fran
		select
			fc.ParentUserID
		,	fc.ChildUserID
		from
			dbo.FranchiseChild fc
		where
			fc.ChildUserID in (@sUserId,@tUserId) 
		union select
			fo.UserID ParentUserID
		,   fo.UserID ChildUserID
		from
			dbo.FranchiseOwner fo
		where
			fo.UserID in (@sUserId,@tUserId) 

		set @fcount = @@ROWCOUNT
		set @badUsers = 0

		if @fcount = 0
			set @badUsers = 0
		else if @fcount = 1
			set @badUsers = 1
		else if @fcount = 2
			begin
				select
					@fcount = count(distinct f.parentId)
				from	
					@fran f

				if @fcount != 1
					set @badUsers = 1
			end

	-- bail if the users are not in the same tier or both are not in the franchise tables   
    if @badUsers = 1
        begin
            set @errstr = 'The source UserId (' + convert(varchar(25),@sUserId) + ') and the target UserId (' +  convert(varchar(25),@tUserId) + ') are not in the same franchise tier.'  
            raiserror(@errstr,11,1)                   
            return          
        end


    -- Archive any existing entries for the target userId
    select
        @result = (
                    select
                        (
                            select 
                                ed.*  
                            from
                                dbo.tblXlinkEFINDatabase ed
                            where
                                ed.[user_id] = @tUserId
                            for 
                               xml PATH('tblXlinkEFINDatabase'), type
                        )
                    ,   (
                            select 
                                os.*  
                            from
                                dbo.tblXlinkOfficeSetup os
                            where
                                os.[user_id] = @tUserId
                            for 
                                xml PATH('tblXlinkOfficeSetup'), type
                        )
                    ,   (
                            select 
                                pd.*  
                            from
                                dbo.tblXlinkPreparerDatabase pd
                            where
                                pd.[user_id] = @tUserId
                            for 
                                xml PATH('tblXlinkPreparerDatabase'), type
                        )
                    ,   (
                            select 
                                rd.*  
                            from
                                dbo.tblXlinkReferralDatabase rd
                            where
                                rd.[user_id] = @tUserId
                            for 
                                xml PATH('tblXlinkReferralDatabase'), type
                        )
                    ,   (
                            select 
                                rf.*  
                            from
                                dbo.tblXlinkRestrictedFields rf
                            where
                                rf.[user_id] = @tUserId
                            for 
                                xml PATH('tblXlinkRestrictedFields'), type
                        )
                    ,   (
                            select 
                                rfrm.*  
                            from
                                dbo.tblXlinkRestrictedForms rfrm
                            where
                                rfrm.[user_id] = @tUserId
                            for 
                                xml PATH('tblXlinkRestrictedForms'), type
                        )
                    ,   (
                            select 
                                ul.*  
                            from
                                dbo.tblXlinkUserLogins ul
                            where
                                ul.[user_id] = @tUserId
                            for 
                                xml PATH('tblXlinkUserLogins'), type
                        )
                    ,   (
                            select 
                                up.*  
                            from
                                dbo.tblXlinkUserProducts up
                            where
                                up.[userid] = @tUserId
                            for 
                                xml PATH('tblXlinkUserProducts'), type
                        )
                    ,   (
                            select 
                                us.*  
                            from
                                dbo.tblXlinkUserSettings us
                            where
                                us.[user_id] = @tUserId
                            for 
                                xml PATH('tblXlinkUserSettings'), type
                        )
                    ,   (
                            select 
                                usc.*  
                            from
                                dbo.tblXlinkUserStatusCodes usc
                            where
                                usc.[user_id] = @tUserId
                            for 
                                xml PATH('tblXlinkUserStatusCodes'), type
                        )
                    ,   (
                            select 
                                xd.*  
                            from
                                dbo.tblXlinkXMLDataForPublish xd
                            where
                                xd.[user_id] = @tUserId
                            for 
                                xml PATH('tblXlinkXMLDataForPublish'), type
                        )
                    ,   (
                            select 
                                m.*  
                            from
                                dbo.tblMgmt m
                            where
                                m.[userid] = @tUserId
                            for 
                                xml PATH('tblMgmt'), type
                        )
                    ,   (
                            select 
                                a.*  
                            from
                                dbo.tblAes a
                            where
                                a.[userid] = @tUserId
                            for 
                                xml PATH('tblAes'), type
                        )
                    for xml PATH('Result'), type
                  )

    insert dbo.tblPortalConfigCopyLog(
        [sourceUserId]
    ,   [targetUserId]
    ,   [targetArchiveXML]
    )
        select
            @sUserId
        ,   @tUserId
        ,   @result



    -- begin the transaction that does the deletes and inserts 
    begin transaction 
        -- wrap it all in a try block to catch any errors and rollback
        begin try 
            -- remove any existing target user Id records
            delete from dbo.tblXlinkEFINDatabase where [user_id] = @tUserId
            delete from dbo.tblXlinkOfficeSetup where [user_id] = @tUserId
            delete from dbo.tblXlinkPreparerDatabase where [user_id] = @tUserId
            delete from dbo.tblXlinkReferralDatabase where [user_id] = @tUserId
            delete from dbo.tblXlinkRestrictedFields where [user_id] = @tUserId
            delete from dbo.tblXlinkRestrictedForms where [user_id] = @tUserId
            delete from dbo.tblXlinkUserLogins where [user_id] = @tUserId
            delete from dbo.tblXlinkUserProducts where [userid] = @tUserId
            delete from dbo.tblXlinkUserSettings where [user_id] = @tUserId
            delete from dbo.tblXlinkUserStatusCodes where [user_id] = @tUserId
            delete from dbo.tblXlinkXMLDataForPublish where [user_id] = @tUserId
            delete from dbo.tblMgmt where [userid] = @tUserId
            delete from dbo.TblAes where [userid] = @tUserId

            -- Insert new target records
            -- tblXlinkEFINDatabase
            insert dbo.tblXlinkEFINDatabase(
                create_date
            ,   edit_date
            ,   publish_date
            ,   account_id
            ,   user_id
            ,   bank
            ,   efin
            ,   company_name
            ,   self_employed
            ,   ssn
            ,   ein
            ,   address
            ,   city
            ,   state
            ,   zip
            ,   office_phone
            ,   first_dcn
            ,   state_code_1
            ,   state_id_1
            ,   state_code_2
            ,   state_id_2
            ,   sbin
            ,   special_bank_app_loc
            ,   default_pin
            ,   transmitter_fee
            ,   sb_fee
            ,   sb_name
            ,   sb_fee_all
            ,   franchiseuser_id
            ,   cell_phone
            ,   cell_phone_carrier
            )
                select
                    a.create_date
                ,   a.edit_date
                ,   a.publish_date
                ,   a.account_id
                ,   @tUserId user_id
                ,   a.bank
                ,   a.efin
                ,   a.company_name
                ,   a.self_employed
                ,   a.ssn
                ,   a.ein
                ,   a.address
                ,   a.city
                ,   a.state
                ,   a.zip
                ,   a.office_phone
                ,   a.first_dcn
                ,   a.state_code_1
                ,   a.state_id_1
                ,   a.state_code_2
                ,   a.state_id_2
                ,   a.sbin
                ,   a.special_bank_app_loc
                ,   a.default_pin
                ,   a.transmitter_fee
                ,   a.sb_fee
                ,   a.sb_name
                ,   a.sb_fee_all
                ,   a.franchiseuser_id
                ,   a.cell_phone
                ,   a.cell_phone_carrier
                from
                    dbo.tblXlinkEFINDatabase a
                where
                    a.[user_id] = @sUserId

            -- tblXlinkOfficeSetup
            insert dbo.tblXlinkOfficeSetup(
                user_id
            ,   account_id
            ,   create_date
            ,   edit_date
            ,   publish_date
            ,   name
            ,   location
            ,   phone
            ,   fax
            ,   email
            ,   transmit_type
            ,   transfer_pdf
            ,   transfer_invoice
            ,   transfer_incomplete
            ,   transfer_complete
            ,   receipt_required
            ,   receipt_auto
            ,   range1begin
            ,   range1end
            ,   range2begin
            ,   range2end
            ,   prevent_transmit
            ,   warning_errors
            ,   override_errors
            ,   default_efin
            ,   dcn_new_efins
            ,   teletax_number
            ,   default_sbin
            ,   assign_dcn_locally
            ,   discard_ack
            ,   auto_pins
            ,   leave_acknowledged
            ,   state_prompt
            ,   company_name
            ,   ein
            ,   company_address
            ,   company_city
            ,   company_state
            ,   company_zip
            ,   self_employed
            ,   eros_name
            ,   eros_ein
            ,   firm_address
            ,   firm_city
            ,   firm_state
            ,   firm_zip
            ,   ero_self_employed
            ,   ero_sbin
            ,   site_id_default
            ,   site_id_required
            ,   auto_add_state_return
            ,   auto_add_state
            ,   default_taxpayers_phone
            ,   allow_only_full_1040
            ,   require_prep_fee
            ,   auto_lock_returns
            ,   auto_add_options
            ,   hide_work_in_progress
            ,   jump_cursor_past_city
            ,   windows_login_name
            ,   default_state_rac
            ,   make_finished_read_only
            ,   font_set
            ,   prior_yr_path
            ,   retrieval_path
            ,   transfer_path
            ,   enable_backup
            ,   backup_path
            ,   billing_scheme
            ,   relationship_1
            ,   age_1
            ,   age_2
            ,   resident_1
            ,   other_1
            ,   other_2
            ,   other_3
            ,   other_4
            ,   other_5
            ,   other_6
            ,   household_1
            ,   household_2
            ,   household_3
            ,   support_1
            ,   support_2
            ,   status_1
            ,   cash_contributions
            ,   noncash_contributions_1
            ,   noncash_contributions_2
            ,   noncash_contributions_3
            ,   noncash_contributions_4
            ,   all_donations
            ,   donations_agi
            ,   unreimbursed_expenses
            ,   unreimbursed_agi
            ,   deductions_1
            ,   deductions_agi_1
            ,   deductions_2
            ,   deductions_agi_2
            ,   describe_docs
            ,   review_returns
            ,   not_purchased_from_relation
            ,   not_purchased_with_bond
            ,   not_received_as_gift
            ,   describe_forms
            ,   verify_proof
            ,   verify_cobra
            ,   form_8880
            ,   verify_ss
            ,   ss_age
            ,   google_mail
            ,   google_password
            ,   cross_collection
            ,   double_entry_validation
            ,   year_to_year_exclude
            ,   child_care_expenses_1
            ,   child_care_expenses_2
            ,   auto_attach_income_and_info
            ,   turn_on_income_and_info
            ,   smtp_server
            ,   smtp_server_port
            ,   franchiseuser_id
            ,   extended_duty
            ,   referral_required
            ,   appointment_firm_name
            ,   appointment_firm_address
            ,   appointment_firm_city
            ,   appointment_firm_state
            ,   appointment_firm_zip
            ,   appointment_firm_phone
            ,   eic_valid_business
            ,   eic_business_expense
            ,   eic_no_expenses
            ,   hoh_earned_income
            ,   print_final
            ,   print_prepname_1040
            ,   auto_add_state_return_w2
            ,   add_print_settings
            ,   prn_adjustment
            ,   prn_remote_printing
            ,   prn_tax_estimation_copies
            ,   prn_ef_declaration_copies
            ,   prn_bank_app_copies
            ,   prn_privacy_letter_copies
            ,   prn_client_data_screen
            ,   prn_bank_fee_estimate_prep
            ,   prn_bank_fee_estimate_cli
            ,   prn_filing_options_prep
            ,   prn_filing_options_cli
            ,   prn_client_letter_prep
            ,   prn_client_letter_cli
            ,   prn_diagnostics
            ,   prn_invoice_prep
            ,   prn_invoice_cli
            ,   prn_tax_comparision_prep
            ,   prn_tax_comparision_cli
            ,   prn_tax_summary_prep
            ,   prn_tax_summary_cli
            ,   prn_income_summary_prep
            ,   prn_income_summary_cli
            ,   prn_fed_return_prep
            ,   prn_fed_return_cli
            ,   prn_state_return_prep
            ,   prn_state_return_cli
            ,   prn_asset_detail_prep
            ,   prn_asset_detail_cli
            ,   prn_asset_detail_fed
            ,   prn_asset_detail_state
            ,   prn_worksheets_prep
            ,   prn_worksheets_cli
            ,   prn_worksheets_fed
            ,   prn_worksheets_state
            ,   prn_overflow_details_prep
            ,   prn_overflow_details_cli
            ,   prn_privacy_letter_prep
            ,   prn_privacy_letter_cli
            ,   prn_appointments_letter_prep
            ,   prn_appointments_letter_cli
            ,   prn_consent_form_prep
            ,   prn_consent_form_cli
            ,   prn_watermark
            ,   prn_send_to_printer_prep
            ,   prn_send_to_printer_cli
            ,   prn_send_to_printer_efile
            ,   prn_send_to_printer_fed
            ,   prn_send_to_printer_state
            ,   prn_send_to_archive_prep
            ,   prn_send_to_archive_cli
            ,   prn_send_to_archive_efile
            ,   prn_send_to_archive_fed
            ,   prn_send_to_archive_state
            ,   prn_asset_detail
            ,   prn_overflow_details
            ,   prn_always_print_signed
            ,   prn_preparer_copy_bank_app
            ,   prn_turn_off_esig
            ,   prn_print_worksheets
            ,   prn_print_single_copy
            ,   prn_print_page_numbers
            ,   prn_print_payment_voucher
            ,   prn_print_site_id
            ,   prn_print_bold
            ,   prn_print_separation
            ,   prn_no_print_invoice_due
            ,   prn_print_tax_summary
            ,   prn_exit_on_print_final
            ,   prn_signature_block
            ,   prn_print_8879
            ,   prn_turn_on_ssn_mask
            ,   prn_do_not_print_itemized_billing
            ,   prn_8879_last_verify
            ,   prn_do_not_print_page2
            ,   include_info_text_message
            ,   print_activities
            ,   box_15
            ,   box_17
            ,   override_print_settings
            ,   savers_credit
            ,   verify_unemployment
            ,   un_age
            ,   verify_hh_status
            ,   prior_year_state
            ,   first_time_home
            ,   year_to_year_exclude_docs
            ,   bus_billing_scheme
            ,   prnbus_client_data_screen
            ,   prnbus_client_letter_prep
            ,   prnbus_client_letter_cli
            ,   prnbus_k1_letter_prep
            ,   prnbus_k1_letter_cli
            ,   prnbus_diagnostics
            ,   prnbus_invoice_prep
            ,   prnbus_invoice_cli
            ,   prnbus_fed_return_prep
            ,   prnbus_fed_return_cli
            ,   prnbus_state_return_prep
            ,   prnbus_state_return_cli
            ,   prnbus_asset_detail_prep
            ,   prnbus_asset_detail_cli
            ,   prnbus_asset_detail_fed
            ,   prnbus_asset_detail_state
            ,   prnbus_worksheets_prep
            ,   prnbus_worksheets_cli
            ,   prnbus_worksheets_fed
            ,   prnbus_worksheets_state
            ,   prnbus_overflow_details_prep
            ,   prnbus_overflow_details_cli
            ,   prnbus_privacy_letter_prep
            ,   prnbus_privacy_letter_cli
            ,   prnbus_watermark
            ,   prnbus_send_to_printer_prep
            ,   prnbus_send_to_printer_cli
            ,   prnbus_send_to_printer_efile
            ,   prnbus_send_to_printer_fed
            ,   prnbus_send_to_printer_state
            ,   prnbus_send_to_archive_prep
            ,   prnbus_send_to_archive_cli
            ,   prnbus_send_to_archive_efile
            ,   prnbus_send_to_archive_fed
            ,   prnbus_send_to_archive_state
            ,   box_15a
            ,   prn_referral_coupons
            ,   auto_save_mins
            ,   gmtc_disable
            ,   silent_save
            ,   no_drugs
            ,   not_graduate
            ,   student_age
            ,   student_under_age
            ,   student_over_age
            ,   qualified_institution
            ,   student_1098t
            ,   student_half_time
            ,   student_claimed_credit
            ,   missing_deductions
            ,   company_phone
            ,   prn_scriptel
            ,   relationship_2
            ,   real_estate_taxes
            ,   mortgage_interest
            ,   prn_disable_signatures
            ,   prn_opt_out_return_transfer
            ,   require_user_status
            ,   yty_include_preparer
            ,   shrink_verify
            ,   prn_exclude_privacy
            ,   prn_inv_8879_8453
            ,   prn_turn_on_ptin_mask
            ,   prn_state_client_letter_prep
            ,   prn_state_client_letter_cli
            ,   prn_state_asset_detail_prep
            ,   prn_state_asset_detail_cli
            ,   prnbus_state_client_letter_prep
            ,   prnbus_state_client_letter_cli
            ,   prnbus_financial_statement_prep
            ,   prnbus_financial_statement_cli
            ,   hoh_filing_status
            ,   mortgage_interest_exceeds
            ,   mortgage_interest_exceeds_2
            ,   require_third_party
            ,   disable_rt_lite
            ,   blind_entry
            ,   use_windows_hotkeys
            ,   prn_signature_block2
            ,   prn_date_pg2
            ,   eic_schedc_loss
            ,   eic_schedc_loss_expenses
            ,   verify_refund_amounts_over
            ,   verify_refund_amount
            ,   prn_coupon_amount
            ,   prn_no_pay_voucher8879
            ,   prn_coupon_expire
            ,   prn_payment_voucher_prep
            ,   prn_payment_voucher_cli
            ,   bypass_key_tracking
            ,   verify_self_prepared
            ,   form_RRB_1099
            ,   prn_send_to_email_prep
            ,   prn_send_to_email_cli
            ,   prn_send_to_email_efile
            ,   prn_send_to_email_fed
            ,   prn_send_to_email_state
            ,   prnbus_send_to_email_prep
            ,   prnbus_send_to_email_cli
            ,   prnbus_send_to_email_efile
            ,   prnbus_send_to_email_fed
            ,   prnbus_send_to_email_state
            ,   prn_ein_masking
            ,   mask_ssn_ein
            )
                select
                    @tUserId user_id
                ,   a.account_id
                ,   a.create_date
                ,   a.edit_date
                ,   a.publish_date
                ,   a.name
                ,   a.location
                ,   a.phone
                ,   a.fax
                ,   a.email
                ,   a.transmit_type
                ,   a.transfer_pdf
                ,   a.transfer_invoice
                ,   a.transfer_incomplete
                ,   a.transfer_complete
                ,   a.receipt_required
                ,   a.receipt_auto
                ,   a.range1begin
                ,   a.range1end
                ,   a.range2begin
                ,   a.range2end
                ,   a.prevent_transmit
                ,   a.warning_errors
                ,   a.override_errors
                ,   a.default_efin
                ,   a.dcn_new_efins
                ,   a.teletax_number
                ,   a.default_sbin
                ,   a.assign_dcn_locally
                ,   a.discard_ack
                ,   a.auto_pins
                ,   a.leave_acknowledged
                ,   a.state_prompt
                ,   a.company_name
                ,   a.ein
                ,   a.company_address
                ,   a.company_city
                ,   a.company_state
                ,   a.company_zip
                ,   a.self_employed
                ,   a.eros_name
                ,   a.eros_ein
                ,   a.firm_address
                ,   a.firm_city
                ,   a.firm_state
                ,   a.firm_zip
                ,   a.ero_self_employed
                ,   a.ero_sbin
                ,   a.site_id_default
                ,   a.site_id_required
                ,   a.auto_add_state_return
                ,   a.auto_add_state
                ,   a.default_taxpayers_phone
                ,   a.allow_only_full_1040
                ,   a.require_prep_fee
                ,   a.auto_lock_returns
                ,   a.auto_add_options
                ,   a.hide_work_in_progress
                ,   a.jump_cursor_past_city
                ,   a.windows_login_name
                ,   a.default_state_rac
                ,   a.make_finished_read_only
                ,   a.font_set
                ,   a.prior_yr_path
                ,   a.retrieval_path
                ,   a.transfer_path
                ,   a.enable_backup
                ,   a.backup_path
                ,   a.billing_scheme
                ,   a.relationship_1
                ,   a.age_1
                ,   a.age_2
                ,   a.resident_1
                ,   a.other_1
                ,   a.other_2
                ,   a.other_3
                ,   a.other_4
                ,   a.other_5
                ,   a.other_6
                ,   a.household_1
                ,   a.household_2
                ,   a.household_3
                ,   a.support_1
                ,   a.support_2
                ,   a.status_1
                ,   a.cash_contributions
                ,   a.noncash_contributions_1
                ,   a.noncash_contributions_2
                ,   a.noncash_contributions_3
                ,   a.noncash_contributions_4
                ,   a.all_donations
                ,   a.donations_agi
                ,   a.unreimbursed_expenses
                ,   a.unreimbursed_agi
                ,   a.deductions_1
                ,   a.deductions_agi_1
                ,   a.deductions_2
                ,   a.deductions_agi_2
                ,   a.describe_docs
                ,   a.review_returns
                ,   a.not_purchased_from_relation
                ,   a.not_purchased_with_bond
                ,   a.not_received_as_gift
                ,   a.describe_forms
                ,   a.verify_proof
                ,   a.verify_cobra
                ,   a.form_8880
                ,   a.verify_ss
                ,   a.ss_age
                ,   a.google_mail
                ,   a.google_password
                ,   a.cross_collection
                ,   a.double_entry_validation
                ,   a.year_to_year_exclude
                ,   a.child_care_expenses_1
                ,   a.child_care_expenses_2
                ,   a.auto_attach_income_and_info
                ,   a.turn_on_income_and_info
                ,   a.smtp_server
                ,   a.smtp_server_port
                ,   a.franchiseuser_id
                ,   a.extended_duty
                ,   a.referral_required
                ,   a.appointment_firm_name
                ,   a.appointment_firm_address
                ,   a.appointment_firm_city
                ,   a.appointment_firm_state
                ,   a.appointment_firm_zip
                ,   a.appointment_firm_phone
                ,   a.eic_valid_business
                ,   a.eic_business_expense
                ,   a.eic_no_expenses
                ,   a.hoh_earned_income
                ,   a.print_final
                ,   a.print_prepname_1040
                ,   a.auto_add_state_return_w2
                ,   a.add_print_settings
                ,   a.prn_adjustment
                ,   a.prn_remote_printing
                ,   a.prn_tax_estimation_copies
                ,   a.prn_ef_declaration_copies
                ,   a.prn_bank_app_copies
                ,   a.prn_privacy_letter_copies
                ,   a.prn_client_data_screen
                ,   a.prn_bank_fee_estimate_prep
                ,   a.prn_bank_fee_estimate_cli
                ,   a.prn_filing_options_prep
                ,   a.prn_filing_options_cli
                ,   a.prn_client_letter_prep
                ,   a.prn_client_letter_cli
                ,   a.prn_diagnostics
                ,   a.prn_invoice_prep
                ,   a.prn_invoice_cli
                ,   a.prn_tax_comparision_prep
                ,   a.prn_tax_comparision_cli
                ,   a.prn_tax_summary_prep
                ,   a.prn_tax_summary_cli
                ,   a.prn_income_summary_prep
                ,   a.prn_income_summary_cli
                ,   a.prn_fed_return_prep
                ,   a.prn_fed_return_cli
                ,   a.prn_state_return_prep
                ,   a.prn_state_return_cli
                ,   a.prn_asset_detail_prep
                ,   a.prn_asset_detail_cli
                ,   a.prn_asset_detail_fed
                ,   a.prn_asset_detail_state
                ,   a.prn_worksheets_prep
                ,   a.prn_worksheets_cli
                ,   a.prn_worksheets_fed
                ,   a.prn_worksheets_state
                ,   a.prn_overflow_details_prep
                ,   a.prn_overflow_details_cli
                ,   a.prn_privacy_letter_prep
                ,   a.prn_privacy_letter_cli
                ,   a.prn_appointments_letter_prep
                ,   a.prn_appointments_letter_cli
                ,   a.prn_consent_form_prep
                ,   a.prn_consent_form_cli
                ,   a.prn_watermark
                ,   a.prn_send_to_printer_prep
                ,   a.prn_send_to_printer_cli
                ,   a.prn_send_to_printer_efile
                ,   a.prn_send_to_printer_fed
                ,   a.prn_send_to_printer_state
                ,   a.prn_send_to_archive_prep
                ,   a.prn_send_to_archive_cli
                ,   a.prn_send_to_archive_efile
                ,   a.prn_send_to_archive_fed
                ,   a.prn_send_to_archive_state
                ,   a.prn_asset_detail
                ,   a.prn_overflow_details
                ,   a.prn_always_print_signed
                ,   a.prn_preparer_copy_bank_app
                ,   a.prn_turn_off_esig
                ,   a.prn_print_worksheets
                ,   a.prn_print_single_copy
                ,   a.prn_print_page_numbers
                ,   a.prn_print_payment_voucher
                ,   a.prn_print_site_id
                ,   a.prn_print_bold
                ,   a.prn_print_separation
                ,   a.prn_no_print_invoice_due
                ,   a.prn_print_tax_summary
                ,   a.prn_exit_on_print_final
                ,   a.prn_signature_block
                ,   a.prn_print_8879
                ,   a.prn_turn_on_ssn_mask
                ,   a.prn_do_not_print_itemized_billing
                ,   a.prn_8879_last_verify
                ,   a.prn_do_not_print_page2
                ,   a.include_info_text_message
                ,   a.print_activities
                ,   a.box_15
                ,   a.box_17
                ,   a.override_print_settings
                ,   a.savers_credit
                ,   a.verify_unemployment
                ,   a.un_age
                ,   a.verify_hh_status
                ,   a.prior_year_state
                ,   a.first_time_home
                ,   a.year_to_year_exclude_docs
                ,   a.bus_billing_scheme
                ,   a.prnbus_client_data_screen
                ,   a.prnbus_client_letter_prep
                ,   a.prnbus_client_letter_cli
                ,   a.prnbus_k1_letter_prep
                ,   a.prnbus_k1_letter_cli
                ,   a.prnbus_diagnostics
                ,   a.prnbus_invoice_prep
                ,   a.prnbus_invoice_cli
                ,   a.prnbus_fed_return_prep
                ,   a.prnbus_fed_return_cli
                ,   a.prnbus_state_return_prep
                ,   a.prnbus_state_return_cli
                ,   a.prnbus_asset_detail_prep
                ,   a.prnbus_asset_detail_cli
                ,   a.prnbus_asset_detail_fed
                ,   a.prnbus_asset_detail_state
                ,   a.prnbus_worksheets_prep
                ,   a.prnbus_worksheets_cli
                ,   a.prnbus_worksheets_fed
                ,   a.prnbus_worksheets_state
                ,   a.prnbus_overflow_details_prep
                ,   a.prnbus_overflow_details_cli
                ,   a.prnbus_privacy_letter_prep
                ,   a.prnbus_privacy_letter_cli
                ,   a.prnbus_watermark
                ,   a.prnbus_send_to_printer_prep
                ,   a.prnbus_send_to_printer_cli
                ,   a.prnbus_send_to_printer_efile
                ,   a.prnbus_send_to_printer_fed
                ,   a.prnbus_send_to_printer_state
                ,   a.prnbus_send_to_archive_prep
                ,   a.prnbus_send_to_archive_cli
                ,   a.prnbus_send_to_archive_efile
                ,   a.prnbus_send_to_archive_fed
                ,   a.prnbus_send_to_archive_state
                ,   a.box_15a
                ,   a.prn_referral_coupons
                ,   a.auto_save_mins
                ,   a.gmtc_disable
                ,   a.silent_save
                ,   a.no_drugs
                ,   a.not_graduate
                ,   a.student_age
                ,   a.student_under_age
                ,   a.student_over_age
                ,   a.qualified_institution
                ,   a.student_1098t
                ,   a.student_half_time
                ,   a.student_claimed_credit
                ,   a.missing_deductions
                ,   a.company_phone
                ,   a.prn_scriptel
                ,   a.relationship_2
                ,   a.real_estate_taxes
                ,   a.mortgage_interest
                ,   a.prn_disable_signatures
                ,   a.prn_opt_out_return_transfer
                ,   a.require_user_status
                ,   a.yty_include_preparer
                ,   a.shrink_verify
                ,   a.prn_exclude_privacy
                ,   a.prn_inv_8879_8453
                ,   a.prn_turn_on_ptin_mask
                ,   a.prn_state_client_letter_prep
                ,   a.prn_state_client_letter_cli
                ,   a.prn_state_asset_detail_prep
                ,   a.prn_state_asset_detail_cli
                ,   a.prnbus_state_client_letter_prep
                ,   a.prnbus_state_client_letter_cli
                ,   a.prnbus_financial_statement_prep
                ,   a.prnbus_financial_statement_cli
                ,   a.hoh_filing_status
                ,   a.mortgage_interest_exceeds
                ,   a.mortgage_interest_exceeds_2
                ,   a.require_third_party
                ,   a.disable_rt_lite
                ,   a.blind_entry
                ,   a.use_windows_hotkeys
                ,   a.prn_signature_block2
                ,   a.prn_date_pg2
                ,   a.eic_schedc_loss
                ,   a.eic_schedc_loss_expenses
                ,   a.verify_refund_amounts_over
                ,   a.verify_refund_amount
                ,   a.prn_coupon_amount
                ,   a.prn_no_pay_voucher8879
                ,   a.prn_coupon_expire
                ,   a.prn_payment_voucher_prep
                ,   a.prn_payment_voucher_cli
                ,   a.bypass_key_tracking
                ,   a.verify_self_prepared
                ,   a.form_RRB_1099
                ,   a.prn_send_to_email_prep
                ,   a.prn_send_to_email_cli
                ,   a.prn_send_to_email_efile
                ,   a.prn_send_to_email_fed
                ,   a.prn_send_to_email_state
                ,   a.prnbus_send_to_email_prep
                ,   a.prnbus_send_to_email_cli
                ,   a.prnbus_send_to_email_efile
                ,   a.prnbus_send_to_email_fed
                ,   a.prnbus_send_to_email_state
                ,   a.prn_ein_masking
                ,   a.mask_ssn_ein
                from
                    dbo.tblXlinkOfficeSetup a
                where
                    a.[user_id] = @sUserId

            -- tblXlinkPreparerDatabase
            insert dbo.tblXlinkPreparerDatabase(
                create_date
            ,   edit_date
            ,   publish_date
            ,   account_id
            ,   user_id
            ,   shortcut_id
            ,   preparer_name
            ,   self_employed
            ,   firm_name
            ,   ein
            ,   address
            ,   city
            ,   state
            ,   zip
            ,   office_phone
            ,   efin
            ,   state_code_1
            ,   state_id_1
            ,   state_code_2
            ,   state_id_2
            ,   ptin
            ,   ssn
            ,   third_party_pin
            ,   email
            ,   preparer_type
            ,   cell_phone
            ,   cell_phone_carrier
            ,   franchiseuser_id
            ,   caf
            )
                select
                    a.create_date
                ,   a.edit_date
                ,   a.publish_date
                ,   a.account_id
                ,   @tUserId user_id
                ,   a.shortcut_id
                ,   a.preparer_name
                ,   a.self_employed
                ,   a.firm_name
                ,   a.ein
                ,   a.address
                ,   a.city
                ,   a.state
                ,   a.zip
                ,   a.office_phone
                ,   a.efin
                ,   a.state_code_1
                ,   a.state_id_1
                ,   a.state_code_2
                ,   a.state_id_2
                ,   a.ptin
                ,   a.ssn
                ,   a.third_party_pin
                ,   a.email
                ,   a.preparer_type
                ,   a.cell_phone
                ,   a.cell_phone_carrier
                ,   a.franchiseuser_id
                ,   a.caf
                from
                    dbo.tblXlinkPreparerDatabase a
                where
                    a.[user_id] = @sUserId

            -- tblXlinkReferralDatabase
            insert dbo.tblXlinkReferralDatabase(
                create_date
            ,   update_date
            ,   publish_date
            ,   account_id
            ,   user_id
            ,   seq_num
            ,   referral
            ,   franchiseuser_id
            )
                select
                    a.create_date
                ,   a.update_date
                ,   a.publish_date
                ,   a.account_id
                ,   @tUserId user_id
                ,   a.seq_num
                ,   a.referral
                ,   a.franchiseuser_id
                from
                    dbo.tblXlinkReferralDatabase a
                where
                    a.[user_id] = @sUserId

            -- tblXlinkRestrictedFields
            insert dbo.tblXlinkRestrictedFields(
                create_date
            ,   update_date
            ,   publish_date
            ,   restricted_field
            ,   account_id
            ,   user_id
            ,   franchiseuser_id

            )
                select
                    a.create_date
                ,   a.update_date
                ,   a.publish_date
                ,   a.restricted_field
                ,   a.account_id
                ,   @tUserId user_id
                ,   a.franchiseuser_id
                from
                    dbo.tblXlinkRestrictedFields a
                where
                    a.[user_id] = @sUserId

            -- tblXlinkRestrictedForms
            insert dbo.tblXlinkRestrictedForms(
                create_date
            ,   update_date
            ,   publish_date
            ,   state_id
            ,   form_id
            ,   restrict_add
            ,   restrict_edit
            ,   account_id
            ,   user_id
            ,   franchiseuser_id

            )
                select
                    a.create_date
                ,   a.update_date
                ,   a.publish_date
                ,   a.state_id
                ,   a.form_id
                ,   a.restrict_add
                ,   a.restrict_edit
                ,   a.account_id
                ,   @tUserId user_id
                ,   a.franchiseuser_id
                from
                    dbo.tblXlinkRestrictedForms a
                where
                    a.[user_id] = @sUserId

            -- tblXlinkUserLogins
            insert dbo.tblXlinkUserLogins(
                create_date
            ,   edit_date
            ,   publish_date
            ,   account_id
            ,   user_id
            ,   login_id
            ,   login_name
            ,   login_password
            ,   change_password
            ,   hide_work_in_progress
            ,   access_level
            ,   shortcut_id
            ,   bank_id_code
            ,   RBIN
            ,   franchiseuser_id
            ,   display_short_form
            ,   training_returns_only
            ,   show_fees_in_transmit
            ,   disabled
            ,   email
            ,   cell_phone
            )
                select
                    a.create_date
                ,   a.edit_date
                ,   a.publish_date
                ,   a.account_id
                ,   @tUserId user_id
                ,   a.login_id
                ,   a.login_name
                ,   a.login_password
                ,   a.change_password
                ,   a.hide_work_in_progress
                ,   a.access_level
                ,   a.shortcut_id
                ,   a.bank_id_code
                ,   a.RBIN
                ,   a.franchiseuser_id
                ,   a.display_short_form
                ,   a.training_returns_only
                ,   a.show_fees_in_transmit
                ,   a.disabled
                ,   a.email
                ,   a.cell_phone
                from
                    dbo.tblXlinkUserLogins a
                where
                    a.[user_id] = @sUserId

            -- tblXlinkUserProducts
            insert dbo.tblXlinkUserProducts(
                userID
            ,   account
            ,   aprodId
            ,   tag
            ,   eroAddonFee
            ,   autoAddFinancial
            ,   autoAddNonFinancial
            ,   createDate
            ,   createBy
            ,   modifyDate
            ,   modifyBy

            )
                select
                    @tUserId userID
                ,   a.account
                ,   a.aprodId
                ,   a.tag
                ,   a.eroAddonFee
                ,   a.autoAddFinancial
                ,   a.autoAddNonFinancial
                ,   a.createDate
                ,   a.createBy
                ,   a.modifyDate
                ,   a.modifyBy
                from
                    dbo.tblXlinkUserProducts a
                where
                    a.[userid] = @sUserId

            -- tblXlinkUserSettings
            insert dbo.tblXlinkUserSettings(
                master_id
            ,   create_date
            ,   edit_date
            ,   publish_date
            ,   user_id
            ,   account_id
            ,   transmit_password
            ,   authorization_level
            ,   name
            ,   phone
            ,   location
            ,   fax
            ,   email
            ,   billing_schedule
            ,   bank_choice
            ,   group_id
            ,   svcB_fee
            ,   protection_plus_fee
            ,   auto_add_audit_protection
            ,   ef_forms_only
            ,   sales_tax
            ,   default_rate
            ,   tax_prep_discount
            ,   disable_invoicing
            ,   collect_on_billing
            ,   EFFee
            ,   DPFee
            ,   transmitter_fee
            ,   main_office_review
            ,   main_office_copy
            ,   lock_returns
            ,   fed_system_messages
            ,   fed_reject_messages
            ,   state_messages
            ,   check_print
            ,   crosslink_1040
            ,   state_return_printing
            ,   protection_plus
            ,   central_site_archive
            ,   transmit_type
            ,   site_id
            ,   prior_setup
            ,   prior_billing
            ,   prior_data
            ,   prior_logins
            ,   admin_password
            ,   enc_key
            ,   lock_flag
            ,   mef_flag
            ,   textlink_messaging
            ,   franchiseuser_id
            ,   prior_appointments
            ,   chk_userid
            ,   prior_franchise_user_id
            ,   self_prepared_fee
            ,   office_info1
            ,   office_info2
            ,   office_info3
            ,   office_info4
            ,   main_office_copy_docs
            ,   hidden
            ,   bus_billing_schedule
            ,   auto_add_cadr_plus
            ,   auto_add_audit_protection_non_financial
            ,   no_prior_year_bal
            ,   auto_add_iProtect
            ,   turn_off_disbursements
            ,   dont_bill_schda
            ,   prevent_transmit_balance_due

            )
                select
                    a.master_id
                ,   a.create_date
                ,   a.edit_date
                ,   a.publish_date
                ,   @tUserId user_id
                ,   a.account_id
                ,   a.transmit_password
                ,   a.authorization_level
                ,   a.name
                ,   a.phone
                ,   a.location
                ,   a.fax
                ,   a.email
                ,   a.billing_schedule
                ,   a.bank_choice
                ,   a.group_id
                ,   a.svcB_fee
                ,   a.protection_plus_fee
                ,   a.auto_add_audit_protection
                ,   a.ef_forms_only
                ,   a.sales_tax
                ,   a.default_rate
                ,   a.tax_prep_discount
                ,   a.disable_invoicing
                ,   a.collect_on_billing
                ,   a.EFFee
                ,   a.DPFee
                ,   a.transmitter_fee
                ,   a.main_office_review
                ,   a.main_office_copy
                ,   a.lock_returns
                ,   a.fed_system_messages
                ,   a.fed_reject_messages
                ,   a.state_messages
                ,   a.check_print
                ,   a.crosslink_1040
                ,   a.state_return_printing
                ,   a.protection_plus
                ,   a.central_site_archive
                ,   a.transmit_type
                ,   a.site_id
                ,   a.prior_setup
                ,   a.prior_billing
                ,   a.prior_data
                ,   a.prior_logins
                ,   a.admin_password
                ,   a.enc_key
                ,   a.lock_flag
                ,   a.mef_flag
                ,   a.textlink_messaging
                ,   a.franchiseuser_id
                ,   a.prior_appointments
                ,   a.chk_userid
                ,   a.prior_franchise_user_id
                ,   a.self_prepared_fee
                ,   a.office_info1
                ,   a.office_info2
                ,   a.office_info3
                ,   a.office_info4
                ,   a.main_office_copy_docs
                ,   a.hidden
                ,   a.bus_billing_schedule
                ,   a.auto_add_cadr_plus
                ,   a.auto_add_audit_protection_non_financial
                ,   a.no_prior_year_bal
                ,   a.auto_add_iProtect
                ,   a.turn_off_disbursements
                ,   a.dont_bill_schda
                ,   a.prevent_transmit_balance_due
                from
                    dbo.tblXlinkUserSettings a
                where
                    a.[user_id] = @sUserId

            -- tblXlinkUserStatusCodes
            insert dbo.tblXlinkUserStatusCodes(
                create_date
            ,   update_date
            ,   publish_date
            ,   account_id
            ,   user_id
            ,   status_code
            ,   status_description
            ,   franchiseuser_id

            )
                select
                    a.create_date
                ,   a.update_date
                ,   a.publish_date
                ,   a.account_id
                ,   @tUserId user_id
                ,   a.status_code
                ,   a.status_description
                ,   a.franchiseuser_id
                from
                    dbo.tblXlinkUserStatusCodes a
                where
                    a.[user_id] = @sUserId

            -- tblXlinkXMLDataForPublish
            insert dbo.tblXlinkXMLDataForPublish(
                Account
            ,   franchiseuser_id
            ,   user_id
            ,   TableName
            ,   XMLTag
            ,   XMLData
            ,   Published
            ,   CreatedDate
            )
                select
                    a.Account
                ,   a.franchiseuser_id
                ,   @tUserId user_id
                ,   a.TableName
                ,   a.XMLTag
                ,   a.XMLData
                ,   a.Published
                ,   a.CreatedDate
                from
                    dbo.tblXlinkXMLDataForPublish a
                where
                    a.[user_id] = @sUserId

            -- tblMgmt
            insert dbo.tblMgmt(
                delivered
            ,   userid
            ,   seqno
            ,   xmldata
            ,   datecreated
            )
                select
                    ' ' delivered
                ,   @tUserId userid
                ,   a.seqno
                ,   a.xmldata
                ,   a.datecreated
                from
                    dbo.tblMgmt a
                where
                    a.[userid] = @sUserId

            -- tblAes
            insert dbo.tblAes(
                userid
            ,   siteid
            ,   aes
            ,   tstamp
            ,   reset
            )
                select
                    @tUserId userid
                ,   a.siteid
                ,   a.aes
                ,   a.tstamp
                ,   a.reset
                from
                    dbo.tblAes a
                where
                    a.[userid] = @sUserId

            -- no errors so commit
            commit transaction

        end try

        begin catch
            rollback transaction

            declare @errMsg         nvarchar(4000)
            declare @errSev         int
            declare @errState       int

            select @errMsg = ERROR_MESSAGE() 
            select @errSev = ERROR_SEVERITY()  
            select @errState = ERROR_STATE()  
            
            raiserror (@errMsg, @errSev, @errState)

        end catch

        









