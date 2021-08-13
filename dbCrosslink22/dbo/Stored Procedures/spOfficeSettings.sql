
-- =============================================
-- Author:		Jay Willis
-- Create date: ??
-- Description:	
-- Update: 11/22/2011 added franchise user code - Jay Willis
-- Update: 10/24/2012 added MAHJOS to CSTM flag - Jay Willis
-- Update: 10/25/2012 added printer settings - Jay Willis
-- Update: 10/31/2012 added include_info_text_message - Jay Willis
-- Update: 11/28/2012 added AGUOLE to CSTM flag - Jay Willi
-- Update: 01/08/2013 added docFlag to userxfr insert - Jay Willis
-- Update: 01/18/2013 added addition flags - Jay Willis
-- Update: 01/18/2013 added flags for 2014 - Jay Willis
-- Update: 10/22/2013 added new office settings - Jay Willis
-- Update: 10/29/2013 added auto add cadr setting - Jay Willis
-- Update: 11/18/2013 added new office setting - Jay Willis
-- Update: 12/16/2013 added new office settings VC55 and VC56 - Jay Willis
-- Update: 08/12/2014 added new CMT1 - CMT9 - Jay Willis
-- =============================================
CREATE PROCEDURE [dbo].[spOfficeSettings] 
	-- Add the parameters for the stored procedure here
	@usersettings_id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE 
		@currentSeason int = dbo.getXlinkSeason(),
		@user_id varchar(6),	@seqno int,				@XMLString varchar(max),		@XMLString2 varchar(150),
		@XMLStringLaunch xml,	@XMLString3 varchar(150),@XMLCSTString varchar(200),	@OutString varchar(max),
		--@1040 char(1),			
		@ACKL char(1),			@APIN char(1),		@ADDR varchar(40),	
		@AAFO char(1),			--@ASGN char(1),			
		@BKST char(1),
		@ARCV varchar(30),		--@AUTC char(1),			
		@AUTX char(1),			@BILL varchar(10),		@BILC varchar(10),
		@BKUP char(1),			@D202 varchar(40),		@D203 char(1),		@D205 varchar(9),
		@D206 varchar(40),		@D207 varchar(20),		@D208 varchar(2),	@D209 varchar(5),
		@D216 varchar(8),		@D303 char(1),			@D304 varchar(40),	@D305 varchar(9),
		@D306 varchar(40),		@D307 varchar(20),		@D308 varchar(2),	@D309 varchar(5),
		--@DDCN varchar(9),		
		@DXFR char(1),			@EFIN char(6),
		@EMAL varchar(40),		@ERRO char(1),			@ERRW char(1),		@ERRX char(1),		
		@ERCD char(1),			@EROS char(2),
		@FAXN char(10),			@GMAL varchar(40),		@GPWD varchar(40),	--@IXFR char(1),
		@LOKF char(1),			@NUMB char(1),
		@OPER varchar(40),		@PFER char(1),			@PHON varchar(10),	@RCPR char(1),
		@RCPA char(1),			@RNH1 varchar(5),		@RNH2 varchar(5),	@RNL1 varchar(5),
		@RNL2 varchar(5),		@RTRV varchar(30),		@SBID varchar(6),	@SRDQ char(1),
		@SIDR char(1),			@SITE varchar(10),		@STEF char(1),		@TELE varchar(14),
		@VC01 char(1),			@VC02 char(1),			@VC03 char(1),		@VC04 char(1),
		@VC05 char(1),			@VC06 char(1),			@VC07 char(1),		@VC08 char(1),
		@VC09 char(1),			@VC10 char(1),			@VC11 char(1),		@VC12 char(1),
		@VC13 char(1),			@VC14 char(1),			@VC15 char(1),		@VC16 char(1),
		@VC17 char(1),			@VC18 char(1),			@VD01 varchar(10),
		@VC24 char(1),			
		@VC25 char(1),			@VC26 char(1),		@VC27 char(1),
		@VC28 varchar(2),		@VC29 char(1),			@VC30 char(1),		@VC31 char(1),
		@VC32 char(1),			@VC33 char(1),			@VC34 char(1),		@VC35 char(1),
		@VC36 char(1),
		@VD02 varchar(10),		@VD03 varchar(10),		@VD04 varchar(10),	
		@USEW char(1),			@WLOK char(1),			@XFER varchar(30),	@XMIT char(1),		
		@YTYD varchar(30),		@ZIPF char(1),			@iSQL varchar(max), @PASS char(8),
		@copyFlag char(1),		@reviewFlag char(1),	@lockFlag char(1),	@fedSysFlag char(1),
		@fedRejFlag char(1),	@stateFlag char(1),		@chkFlag char(1),	@masterUser char(6),
-- New for 2011
		@DEBT char(1),			@DBRE char(1),			@YTYF char(1),		@VC37 char(1),
		@VC38 char(1),			@INSC char(1),			@INSV char(1),		@STPS varchar(40),
		@STPP varchar(5),		@REFV char(1),
		@Chk_UserID varchar(6),	@APPF varchar(34),		@APPA varchar(34),	@APPC varchar(20),
		@APPS char(2),			@APPZ varchar(9),		@APPP varchar(10),	@VD05 varchar(3),
		@VD07 varchar(3),		@VD08 varchar(3),		@VD06 varchar(5),
		@Franchiseuserid int,	@CSTM varchar(4),		@account_id varchar(8), @MRKZ varchar(1), 
		@PRPN varchar(1),		/*@AUDF char(1),*/			@Franchiseowner int,
-- New for 2012
		--@AAW2 char(1),			
		@CHKT int,				@CHKS char(1),			@TEP1 int,	
		@TEP2 int,				@TEP3 int,				@TEP4 int,			@CDS1 char(1),	
		@LBE1 char(1),			@LBE2 char(1),			@LBF1 char(1),		@LBF2 char(1),	
		@LPA1 char(1),			@LPB1 char(1),			@LPA2 char(1),		@LPA3 char(1),	
		@LPB3 char(1),			@LTCA char(1),			@LTCB char(1),		@LTSA char(1),	
		@LTSB char(1),			@LPA4 char(1),			@LPB4 char(1),		@LPA5 char(1),	
		@LPB5 char(1),			@LPA6 char(1),			@LPB6 char(1),		@LPA7 char(1),	
		@LPB7 char(1),			@LPC7 char(1),			@LPD7 char(1),		@LPA8 char(1),	
		@LPB8 char(1),			@LPC8 char(1),			@LPD8 char(1),		@LMDA char(1),	
		@LMDB char(1),			@LPTA char(1),			@LPTB char(1),		@LPSA char(1),	
		@LPSB char(1),			@LPCO char(1),			@LPCP char(1),		@LPWB char(1),	
		@LPA9 char(1),			@LPB9 char(1),			@LPC9 char(1),		@LPD9 char(1),	
		@LPE9 char(1),			@LPBA char(1),			@LPCA char(1),	
		@LPDA char(1),			@LPEA char(1),			@LSRD char(1),		@LSRO char(1),	
		@LSRS char(1),			@ESFP char(1),			@LSRW char(1),	
		@LPSC char(1),			@LPSN char(1),			@LSRV char(1),		@LPSI char(1),	
		@BOLD char(1),			@LPSP char(1),			@IDUE char(1),		@TSBD char(1),	
		@EXPF char(1),			@SBLK char(1),			@BDPO char(1),		@MSSN char(1),	
		@ITMZ char(1),			@LPVA char(1),			@INV2 char(1),		@add_print_settings bit,
		@TEFN char(1),
-- New for 2013
		@docFlag char(1),		@VC40 char(1),			@VC51 char(1),		@VC52 char(1),
		@VC45 char(1),			@VC46 char(1),			@VC47 int,			@VC42 char(1),
		@VC48 char(1),			@VC43 char(1),			@YTYS char(1),
-- New for 2014
		@CCD1 char(1),		@CPA1 char(1),		@CPB1 char(1),		@CPK1 char(1),
		@CPK2 char(1),		@CPA2 char(1),		@CPA3 char(1),		@CPB3 char(1),
		@CPA5 char(1),		@CPB5 char(1),		@CPA6 char(1),		@CPB6 char(1),
		@CPA7 char(1),		@CPB7 char(1),		@CPC7 char(1),		@CPD7 char(1),
		@CPA8 char(1),		@CPB8 char(1),		@CPC8 char(1),		@CPD8 char(1),
		@CMDA char(1),		@CMDB char(1),		@CPTA char(1),		@CPTB char(1),
		@CPWB char(1),		@CPA9 char(1),		@CPB9 char(1),		@CPC9 char(1),
		@CPD9 char(1),		@CPE9 char(1),		@CPBA char(1),
		@CPCA char(1),		@CPDA char(1),		@CPEA char(1),		@VC53 char(1),
		@LPRB char(1),		@ASAV varchar(3),	@GMTC char(1),		@AUTS char(1),
		@VC19 char(1),		@VC20 char(1),		@VC21 char(1),		@VC49 varchar(2),
		@VC50 varchar(2),	@VC22 char(1),		@VC23 char(1),		@VC39 char(1),
		@VC41 char(1),		@VC44 char(1),		@D310 varchar(10),
		/*@ACAD char(1),*/	@VC54 char(1),		@VC55 char(1),		@VC56 char(1),
		@publishdate datetime,					@ISSP char(1),		@AUTN char(1),
		@XMLTag varchar(12),
		@XMLData varchar(max),
		@account varchar(8),
		@override_print_settings bit,
		/*@AUDN char(1),*/
-- New for 2015
		--,	@CST1 varchar(4)	,	@CST2 varchar(4)	,	@CST3 varchar(4)	,	@CST4 varchar(4)
		--,	@CST5 varchar(4)	,	@CST6 varchar(4)	,	@CST7 varchar(4)	,	@CST8 varchar(4)
		--,	@CST9 varchar(4)
			@PRVX char(1)	 	,	@INEF char(1)		,	@LPF7 char(1)		,	@LPE7 char(1)
		,	@LPD1 char(1)		,	@LPC1 char(1)		,	@MPTN char(1)		,	@CPD1 char(1)
		,	@CPC1 char(1)		,	@USST char(1)		,	@VFSK char(1)		,	@YTYP char(1)
		,	@CPA4 char(1)		,	@CPB4 char(1)		,	@VC57 char(1)		,   @VC58 char(1)
		,	@VD09 int			/*,	@ADIP char(1)*/		,	@RTPD char(1)
-- New for 2016
		 -- ticketid 82094
		-- ,	@RTLT char(1)		
		,	@SBLW char(1)		,	@PDP2 char(1)		,	@MSKA char(1)
		,	@MNUW char(1)		,	@VC59 char(1)		,	@VD59 int			,	@RLIX char(1)
		,	@RLIM int			,	@RFAM money			,	@PMTV char(1)		,	@RFEX varchar(30)
-- New for 2017
		,	@MEIN char(1)		,	@LPAB char(1)		,	@LPBB char(1)		,	@KEYT char(1)
		,	@VC61 char(1)		,	@VC60 char(1)		,	@LPAM char(1)		,	@LPBM char(1)
		,	@LPCM char(1)		,	@LPDM char(1)		,	@LPEM char(1)		,	@CPAM char(1)
		,	@CPBM char(1)		,	@CPCM char(1)		,	@CPDM char(1)		,	@CPEM char(1)
		,	@MKID char(1)		,	@EICX char(1)		,	@NBKS char(1)		,	@MRTN char(1)
		,	@CPCI char(1)
--New for 2018
		,	@LSES char(1)		,	@VC65 char(1)		,	@VD10 int			,	@LPA0 char(1)
		,	@VC62 char(1)		,	@VC63 char(1)		,	@VC64 char(1)		,	@OFID varchar(8)
		,	@FPDT char(1)		,	@adminEmail varchar(50)						,	@adminCell varchar(10)
--New for 2019
		,	@AASH char(1)		,	@EROB char(1)		,	@ERCB char(1)		,	@VC68 char(1)		
		,	@ERCR char(1)		,	@YTYB char(1)		,	@EPMT char(1)		
		,	@VC67 char(1)		,	@VD67 int
--New for 2020
		,	@VC70 char(1)		,	@VC71 char(1)		,	@CPCH char(1)		,	@EMAM char(1)
		,	@LACA char(1)		,	@LACB char(1)		,	@PFBA char(1)		,	@PFBB char(1)
		,	@IMTC char(1)		,	@WA03 varchar(18)	,	@WB03 varchar(80)	,	@WA04 varchar(18)	
		,	@WB04 varchar(80)	,	@WA05 varchar(18)	,	@WB05 varchar(80)	,	@ERC1 char(1)
		--,	@XFLT char(1)		
    ,	@VC72 char(1)
--New for 2021
		,	@VC69 char(1)   ,	@VC73 char(1)		,	@LPB0 char(1)		
    ,	@LPAC char(1)		,	@LPBC char(1)		,	@CPAC char(1)		,	@CPBC char(1)
	,	@VC77 char(1)		, @print_order varchar(2048)
	,	@VC74 char(1)		,	@VC75 char(1)		,	@VC76 char(1)		
	-- get user_id
	SELECT	@user_id = user_id, 
 		    @OPER = name, 
		    @PHON = phone,
		    @ADDR = location,
		    @FAXN = fax,
		    @EMAL = email,
			--@AUDF = ISNULL(auto_add_audit_protection, ''),
			--@ADIP = ISNULL(auto_add_iProtect, ''),
			--@AUDN = ISNULL(auto_add_audit_protection_non_financial, ''),
			--@ACAD = ISNULL(auto_add_cadr_plus, ''),							
			--@PASS = IsNull(transmit_password, ''),  get directly from tbluser
			@copyFlag = IsNull(main_office_copy, ''),	
			@docFlag = IsNull(main_office_copy_docs, ''),	
			-- review flaq will always be set by the transmit type
			--@reviewFlag = IsNull(main_office_review, ''),
			@fedSysFlag = CASE IsNull(fed_system_messages, '')
				WHEN 'O' THEN 1
				WHEN 'B' THEN 3
				WHEN 'F' THEN 5
				WHEN 'M' THEN 7
			END,
			@fedRejFlag = CASE IsNull(fed_reject_messages, '')
				WHEN 'O' THEN 1
				WHEN 'B' THEN 3
				WHEN 'F' THEN 5
				WHEN 'M' THEN 7
			END,
			@stateFlag = CASE IsNull(state_messages, '')
				WHEN 'O' THEN 1
				WHEN 'B' THEN 3
				WHEN 'F' THEN 5
				WHEN 'M' THEN 7
			END,
			-- @chkFlag not used any more well maybe...
			@chkFlag = CASE IsNull(check_print, '')
				WHEN 'O' THEN 1 
				WHEN 'M' THEN 2
				WHEN 'F' THEN 4
			END,
			@masterUser = master_id,
			@account = account_id,
			@XMIT = transmit_type,
			@BILL = billing_schedule,
			@BILC = bus_billing_schedule,
			@lockFlag = lock_flag,
			@Chk_UserID = chk_userid,
  			@Franchiseuserid = ISNULL(franchiseuser_id, 0),
			@adminEmail = password_recovery_email,
			@adminCell = password_recovery_phone

	FROM tblXlinkUserSettings WHERE usersettings_id = @usersettings_id

	--get eroid
	Select @OFID = eroid from dbCrosslinkGlobal..tblUser where user_id = @user_id

	--get transmit password
	Select @PASS = ISNULL(passwd, '') from dbCrosslinkGlobal..tbluser where user_id = @user_id

	-- get last sequence number and increment by 1
	SELECT @seqno = 0
	SELECT TOP 1 @seqno = seqno FROM tblMgmt WHERE userid = @user_id ORDER BY seqno DESC
	SELECT @seqno = @seqno + 1

	SELECT	--@1040 = allow_only_full_1040,	
			@ACKL = discard_ack, 			@APIN = auto_pins,
			@AAFO = auto_add_options,
			--@ASGN = assign_dcn_locally,		
			@AUTX = transfer_incomplete,
			--@AUTC = transfer_complete,		
			@BKST = leave_acknowledged,		@BKUP = enable_backup,
			@D202 = eros_name,				@D203 = ero_self_employed,
			@D205 = eros_ein,				@D206 = firm_address,			@D207 = firm_city,
			@D208 = firm_state,				@D209 = firm_zip,				@D216 = ero_sbin,
			@D303 = self_employed,			@D304 = company_name,			@D305 = ein,
			@D306 = company_address,		@D307 = company_city,			@D308 = company_state,
			@D309 = company_zip,			--@DDCN = dcn_new_efins,  		
			@DXFR = transfer_pdf,
			@EFIN = default_efin,			@ERRO = override_errors,
			@ERRW = warning_errors,			@ERCD = auto_add_state_return,	@EROS = auto_add_state,	
			@ERRX = CASE IsNull(prevent_transmit, '')
				WHEN 'F' THEN '0'
				WHEN 'E' THEN '1'
				WHEN 'A' THEN 'X'
			END,
			@GMAL = google_mail,			@GPWD = google_password,		--@IXFR = transfer_invoice,
			@LOKF = auto_lock_returns,		@NUMB = default_taxpayers_phone,
			@PFER = require_prep_fee,		
			@RCPR = receipt_required,		@RCPA = receipt_auto,			@RNH1 = range1end,			
			@RNH2 = range2end,				@RNL1 = range1begin,			@RNL2 = range2begin,		
			@SBID = default_sbin,			@SITE = site_id_default,		@SRDQ = default_state_rac,
			@SIDR = site_id_required,		@STEF = state_prompt,			@TELE = teletax_number,
			@VC01 = relationship_1,			@VC02 = age_1,					@VC03 = age_2,
			@VC04 = resident_1,				@VC05 = other_1,				@VC06 = other_2,
			@VC07 = other_3,				@VC08 = other_4,				@VC09 = cash_contributions,
			@VC10 = noncash_contributions_1,@VC11 = noncash_contributions_2,@VC12 = noncash_contributions_3,
			@VC13 = noncash_contributions_4,@VC14 = all_donations,			@VC15 = unreimbursed_expenses,
			@VC16 = deductions_1,			@VC17 = deductions_2,			@VC18 = describe_forms,
			@VD01 = donations_agi,
			@VC24 = verify_proof,			
			@VC25 = verify_cobra,			@VC26 = form_8880,
			@VC27 = verify_ss,				@VC28 = ss_age,					@VC29 = household_1,
			@VC30 = household_2,			@VC31 = household_3,			@VC32 = other_5,
			@VC33 = other_6,				@VC34 = support_1,				@VC35 = support_2,
			@VC36 = status_1,
			@VD02 = unreimbursed_agi,		@VD03 = deductions_agi_1,		@VD04 = deductions_agi_2,
			@USEW = windows_login_name,		@WLOK = make_finished_read_only, 
			@ZIPF = jump_cursor_past_city,	
-- New for 2011
			@DEBT = cross_collection,		@DBRE = double_entry_validation,@YTYF = year_to_year_exclude,
			@VC37 = child_care_expenses_1,  @VC38 = child_care_expenses_2,  @INSC = auto_attach_income_and_info,
			@INSV = turn_on_income_and_info,@STPS = smtp_server,			@STPP = smtp_server_port,
			@REFV = referral_required,		@APPF = appointment_firm_name,
			@APPA = appointment_firm_address,@APPC = appointment_firm_city,	@APPS = appointment_firm_state,
			@APPZ = appointment_firm_zip,	@APPP = appointment_firm_phone, @VD05 = eic_no_expenses,
			@VD07 = eic_valid_business,		@VD08 = eic_business_expense,	@VD06 = hoh_earned_income,
			@account_id = account_id,		@MRKZ = print_final,			@PRPN = print_prepname_1040,
-- New for 2012
			--@AAW2 = auto_add_state_return_w2,		
			@CHKT = prn_adjustment,					@CHKS = prn_remote_printing,	
			@TEP1 = prn_tax_estimation_copies,		@TEP2 = prn_ef_declaration_copies,	@TEP3 = prn_bank_app_copies,	
			@TEP4 = prn_privacy_letter_copies,		@CDS1 = prn_client_data_screen,		@LBE1 = prn_bank_fee_estimate_prep,	
			@LBE2 = prn_bank_fee_estimate_cli,		@LBF1 = prn_filing_options_prep,	@LBF2 = prn_filing_options_cli,	
			@LPA1 = prn_client_letter_prep,			@LPB1 = prn_client_letter_cli,		@LPA2 = prn_diagnostics,	
			@LPA3 = prn_invoice_prep,				@LPB3 = prn_invoice_cli,			@LTCA = prn_tax_comparision_prep,	
			@LTCB = prn_tax_comparision_cli,		@LTSA = prn_tax_summary_prep,		@LTSB = prn_tax_summary_cli,
			@LPA4 = prn_income_summary_prep,		@LPB4 = prn_income_summary_cli,		@LPA5 = prn_fed_return_prep,	
			@LPB5 = prn_fed_return_cli,				@LPA6 = prn_state_return_prep,		@LPB6 = prn_state_return_cli,	
			@LPA7 = prn_asset_detail_prep,			@LPB7 = prn_asset_detail_cli,		@LPC7 = prn_asset_detail_fed,	
			@LPD7 = prn_asset_detail_state,			@LPA8 = prn_worksheets_prep,		@LPB8 = prn_worksheets_cli,	
			@LPC8 = prn_worksheets_fed,				@LPD8 = prn_worksheets_state,		@LMDA = prn_overflow_details_prep,	
			@LMDB = prn_overflow_details_cli,		@LPTA = prn_privacy_letter_prep,	@LPTB = prn_privacy_letter_cli,	
			@LPSA = prn_appointments_letter_prep,	@LPSB = prn_appointments_letter_cli,	@LPCO = prn_consent_form_prep,	
			@LPCP = prn_consent_form_cli,			@LPWB = prn_watermark,				@LPA9 = prn_send_to_printer_prep,	
			@LPB9 = prn_send_to_printer_cli,		@LPC9 = prn_send_to_printer_efile,	@LPD9 = prn_send_to_printer_fed,	
			@LPE9 = prn_send_to_printer_state,		@LPBA = prn_send_to_archive_cli,	
			@LPCA = prn_send_to_archive_efile,		@LPDA = prn_send_to_archive_fed,	@LPEA = prn_send_to_archive_state,	 
			@LSRD = prn_asset_detail,				@LSRO = prn_overflow_details,		@LSRS = prn_always_print_signed,	
			@ESFP = prn_turn_off_esig,				@LSRW = prn_print_worksheets,	
			@LPSC = prn_print_single_copy,			@LPSN = prn_print_page_numbers,		@LSRV = prn_print_payment_voucher,	
			@LPSI = prn_print_site_id,				@BOLD = prn_print_bold,				@LPSP = prn_print_separation,	
			@IDUE = prn_no_print_invoice_due,		@TSBD = prn_print_tax_summary,		@EXPF = prn_exit_on_print_final,	
			@SBLK = prn_signature_block,			@BDPO = prn_print_8879,				@MSSN = prn_turn_on_ssn_mask,	
			@ITMZ = prn_do_not_print_itemized_billing,	@LPVA = prn_8879_last_verify,	@INV2 = prn_do_not_print_page2,
			@TEFN = include_info_text_message,
			@add_print_settings = add_print_settings, @override_print_settings = override_print_settings,
			@publishdate = publish_date,
-- New for 2013
			@VC40 = print_activities,				@VC51 = box_15,						@VC52 = box_17,
			@VC45 = savers_credit,					@VC46 = verify_unemployment,		@VC47 = un_age,
			@VC42 = verify_hh_status,				@VC48 = prior_year_state,			@VC43 = first_time_home,
			@YTYS = year_to_year_exclude_docs,
-- New for 2014
			@CCD1 = prnbus_client_data_screen,		@CPA1 = prnbus_client_letter_prep,	@CPB1 = prnbus_client_letter_cli,
			@CPK1 = prnbus_k1_letter_prep,			@CPK2 = prnbus_k1_letter_cli,		@CPA2 = prnbus_diagnostics,
			@CPA3 = prnbus_invoice_prep,			@CPB3 = prnbus_invoice_cli,			@CPA5 = prnbus_fed_return_prep,
			@CPB5 = prnbus_fed_return_cli,			@CPA6 = prnbus_state_return_prep,	@CPB6 = prnbus_state_return_cli,
			@CPA7 = prnbus_asset_detail_prep,		@CPB7 = prnbus_asset_detail_cli,	@CPC7 = prnbus_asset_detail_fed,
			@CPD7 = prnbus_asset_detail_state,		@CPA8 = prnbus_worksheets_prep,		@CPB8 = prnbus_worksheets_cli,
			@CPC8 = prnbus_worksheets_fed,			@CPD8 = prnbus_worksheets_state,	@CMDA = prnbus_overflow_details_prep,
			@CMDB = prnbus_overflow_details_cli,	@CPTA = prnbus_privacy_letter_prep,	@CPTB = prnbus_privacy_letter_cli,
			@CPWB = prnbus_watermark,				@CPA9 = prnbus_send_to_printer_prep,@CPB9 = prnbus_send_to_printer_cli,
			@CPC9 = prnbus_send_to_printer_efile,	@CPD9 = prnbus_send_to_printer_fed,	@CPE9 = prnbus_send_to_printer_state,
			@CPBA = prnbus_send_to_archive_cli,		@CPCA = prnbus_send_to_archive_efile,
			@CPDA = prnbus_send_to_archive_fed,		@CPEA = prnbus_send_to_archive_state,@VC53= box_15a,
			@LPRB = prn_referral_coupons,			@AUTS = silent_save,					@GMTC = gmtc_disable,
			@ASAV = CONVERT(varchar(3), auto_save_mins),
			@VC19 = no_drugs,						@VC20 = not_graduate,				@VC21 = student_age,
			@VC49 = student_under_age,				@VC50 = student_over_age,			@VC22 = qualified_institution,
			@VC23 = student_1098t,					@VC39 = student_half_time,			@VC41 = student_claimed_credit,
			@VC44 = missing_deductions,				@D310 = company_phone,
			@VC54 = relationship_2,					@VC55 = real_estate_taxes,			@VC56 = mortgage_interest,
			@ISSP = prn_disable_signatures,			@AUTN = prn_opt_out_return_transfer
-- New for 2015
			,	@PRVX = prn_exclude_privacy					,	@INEF = prn_inv_8879_8453
			,	@LPF7 = prn_state_asset_detail_cli			,	@LPE7 = prn_state_asset_detail_prep
			,	@LPD1 = prn_state_client_letter_cli			,	@LPC1 = prn_state_client_letter_prep
			,	@MPTN = prn_turn_on_ptin_mask				,	@CPD1 = prnbus_state_client_letter_cli
			,	@CPC1 = prnbus_state_client_letter_prep		,	@USST = require_user_status
			,	@VFSK = shrink_verify						,	@YTYP = yty_include_preparer
			,	@CPA4 = prnbus_financial_statement_prep		,	@CPB4 = prnbus_financial_statement_cli
			,	@VC57 = hoh_filing_status					,	@VC58 = mortgage_interest_exceeds
			,	@VD09 = mortgage_interest_exceeds_2			,   @RTPD = require_third_party
-- New for 2016
		    -- ticketid 82094
			-- ,	@RTLT = disable_rt_lite						
			,	@SBLW = prn_signature_block2
			,	@PDP2 = prn_date_pg2						,	@MSKA = blind_entry
			,	@MNUW = use_windows_hotkeys					,	@VC59 = eic_schedc_loss
			,	@VD59 = eic_schedc_loss_expenses			,	@RLIX = verify_refund_amounts_over
			,	@RLIM = verify_refund_amount				,	@RFAM = prn_coupon_amount
			,	@PMTV = prn_no_pay_voucher8879				,	@RFEX = prn_coupon_expire
-- New for 2017
			,	@MEIN = prn_ein_masking						,	@LPAB = prn_payment_voucher_prep
			,	@LPBB = prn_payment_voucher_cli				,	@KEYT = bypass_key_tracking
			,	@VC61 = verify_self_prepared				,	@VC60 = form_RRB_1099
			,	@LPAM = prn_send_to_email_prep				,	@LPBM = prn_send_to_archive_cli
			,	@LPCM = prn_send_to_archive_efile			,	@LPDM = prn_send_to_archive_fed
			,	@LPEM = prn_send_to_archive_state			,	@CPAM = prnbus_send_to_email_prep
			,	@CPBM = prnbus_send_to_email_cli			,	@CPCM = prnbus_send_to_email_efile
			,	@CPDM = prnbus_send_to_email_fed			,	@CPEM = prnbus_send_to_email_state
			,	@MKID = mask_ssn_ein						,	@EICX = disable_eic_checklist
			,	@NBKS = leave_acknowledged_nbp				,	@MRTN = turn_on_acct_masking
			,	@CPCI = require_cell_carrier
-- New for 2018
			,	@LSES = do_not_print_1040ES					,	@VC65 = auto_add_1040es
			,	@VD10 = auto_add_1040es_2					,	@LPA0 = prn_8453_prep
			,	@VC62 = part_ira_nondeductable				,	@VC63 = verify_name_change
			,	@VC64 = verify_itin							,	@FPDT = require_signature_print_date
-- New for 2019
			,	@AASH = auto_add_schedules					,	@EROB = auto_add_state_bus
			,	@ERCB = auto_add_state_return_bus			,	@VC68 = consent_to_use_signed
			,	@ERCR = disable_auto_state					,	@YTYB = include_bank_info
			,	@EPMT = require_EF_PMT
			,	@VC67 = ssa_1099_medicare					,	@VD67 = ssa_1099_medicare_percent
-- New for 2020
			,	@VC70 =	verify_ip_pin						,	@VC71 = verify_yty_address
			,	@LACA = prn_fed_aca_letter_prep				,	@LACB = prn_fed_aca_letter_cli
			,	@PFBA = prn_bank_app_prep					,	@PFBB = prn_bank_app_cli
			,	@CPCH = require_cell_phone					,	@EMAM = require_email_address
			,	@IMTC = interview_forms_tree_color			,	@WA03 = custom_url1_title
			,	@WB03 = custom_url1							,	@WA04 = custom_url2_title
			,	@WB04 = custom_url2							,	@WA05 = custom_url3_title
			,	@WB05 = custom_url3							,	@ERC1 = disable_auto_state_bus
			--,	@XFLT = show_transmit_queue					
      ,	@VC72 = credit_disallowance
-- New for 2021
      ,	@LPB0 = prn_8453_cli          ,	@VC69 = auto_add_verify
      ,	@VC73 = enable_due_diligence  ,	@LPAC = prn_engagement_letter_prep
      ,	@LPBC = prn_engagement_letter_cli      ,	@CPAC = prnbus_engagement_letter_prep
      ,	@CPBC = prnbus_engagement_letter_cli  , @print_order = print_order
	  , @VC77 = verify_prior_year
	  , @VC74 = verify_7202				, @VC75 = verify_cash_donations
	  , @VC76 = validate_covid19

				FROM tblXlinkOfficeSetup 

	where user_id = @user_id
	      AND ISNULL(franchiseuser_id, 0) = @Franchiseuserid

-- if transmit type is not a feeder '0' then uncheck the reviewFlag
	If @XMIT <> '0' 
	BEGIN Select @reviewFlag = '' END
	ELSE
	BEGIN Select @reviewFlag = 'X' END

-- if Franchise Owner set flag
	SELECT @Franchiseowner = count(*) FROM FranchiseOwner WHERE UserID = @user_id

	If RTrim(@user_id) = RTrim(@masterUser) OR @Franchiseowner = 1
	BEGIN
		SELECT @XMLString2 = '<SBUR>X</SBUR>',
-- if this office is the master then don't require review
		@reviewFlag = ''
	END
	ELSE
	BEGIN
		SELECT @XMLString2 = ''
	END
	EXEC dbCrosslinkGlobal..up_getCustomTags @account, @user_id, @currentSeason, @XMLCSTString OUTPUT
	print @XMLCSTString
	EXEC up_getProductTags @user_id, @OutString OUTPUT
	print @OutString



	--If LEFT(@account, 6) = 'RIVEDG'
	--	Select @CST9 = 'UTAX'
	
	--Select @CST1 = CASE IsNull(@account, '')
	--			--WHEN 'PETZ01' THEN '104A' 
	--			WHEN 'SPEMIC00' THEN '104A' 
	--			WHEN 'SPEMIC01' THEN '104A' 
	--			WHEN 'BREBOB' THEN 'RNGB' 
	--			WHEN 'ELBMIT' THEN 'BMIT'
	--			WHEN 'ODNMIL' THEN 'BMIT'
	--			WHEN 'OQBFES' THEN 'ITSF'
	--			--WHEN 'QATEST' THEN 'RNGB'
	--			WHEN 'AGUOLE' THEN 'AOLE'
	--			--WHEN 'QATEST01' THEN 'ITSF'
	--			--WHEN 'QATEST02' THEN 'MITS'
	--			WHEN 'MAHJOS' THEN 'MITS' -- added JW 10/24/12
	--			WHEN 'MAHJOS04' THEN 'MITS' -- added JW 11/03/14
	--			WHEN 'ALEJAC00' THEN 'MITS' -- added JW 11/03/14
	--			WHEN 'HOPKEV' THEN 'TODD' -- added JW 11/17/14
	--			WHEN 'MIRJOH' THEN 'PADP' -- added JW 11/19/14
	--			WHEN 'TRATES' THEN 'UTAX' -- added JW 12/11/2014
	--			ELSE @CST1
	--		END
			
	--Select @CST2 = CASE IsNull(@account, '')
	--			WHEN 'SPEMIC00' THEN 'WFIN' 
	--			WHEN 'RIVEDG17' THEN 'STAX'
	--			WHEN 'HOPKEV' THEN 'IPRP' -- added JW 11/17/14
	--			--WHEN 'QATEST' THEN 'X'
	--			ELSE @CST2
	--		END
	
-- if transmit password is blank don't overwrite
	If @PASS > ''
	BEGIN
		SELECT @XMLString3 = '<PASS>' + @PASS + '</PASS>'
	END
	ELSE
	BEGIN
		SELECT @XMLString3 = ''
	END

	SELECT @XMLString = '<xmldata><cmnd>Global</cmnd>' + @XMLString2 -- + '<ADIP>' + ISNULL(@ADIP, '')  +  '</ADIP><AUDF>' + ISNULL(@AUDF,'') + '</AUDF><AUDN>' + ISNULL(@AUDN,'') + '</AUDN><ACAD>' + ISNULL(@ACAD,'') + '</ACAD>'
	
	--IF CHARINDEX('>104A</CST',@XMLCSTString) <> 0
	--BEGIN
		--SELECT @XMLString = @XMLString + '<_0x003104A>X</_0x003104A>'
	--END

-- if the office settings have never been published then send entire record
if @publishdate is null
BEGIN
			SELECT @XMLString = @XMLString
			--+ '<_0x0031_040>' + ISNULL(@1040,'') + '</_0x0031_040>'	
			+ '<ACKL>' + ISNULL(@ACKL,'') + '</ACKL>'
			+ '<APIN>' + ISNULL(@APIN,'') + '</APIN>'	+ '<AAFO>' + ISNULL(@AAFO,'') + '</AAFO>'
			+ '<ADDR>' + ISNULL(@ADDR,'') + '</ADDR>'	
			--+ '<AUTC>' + ISNULL(@AUTC,'') + '</AUTC>'	
			+ '<AUTX>' + ISNULL(@AUTX,'') + '</AUTX>'
			--+ '<ASGN>' + ISNULL(@ASGN,'') + '</ASGN>'
--			+ '<BILL>I' + ISNULL(@BILL,'') + '</BILL>' -- moved to below
			+ '<BKUP>' + ISNULL(@BKUP,'') + '</BKUP>'	
			+ '<BKST>' + ISNULL(@BKST,'') + '</BKST>'	
			+ '<D202>' + ISNULL(@D202,'') + '</D202>'
			+ '<D203>' + ISNULL(@D203,'') + '</D203>'	+ '<D205>' + ISNULL(@D205,'') + '</D205>'
			+ '<D206>' + ISNULL(@D206,'') + '</D206>'	+ '<D207>' + ISNULL(@D207,'') + '</D207>'
			+ '<D208>' + ISNULL(@D208,'') + '</D208>'	+ '<D209>' + ISNULL(@D209,'') + '</D209>'
			+ '<D216>' + ISNULL(@D216,'') + '</D216>'	+ '<D303>' + ISNULL(@D303,'') + '</D303>'
			+ '<D304>' + ISNULL(@D304,'') + '</D304>'	+ '<D305>' + ISNULL(@D305,'') + '</D305>'
			+ '<D306>' + ISNULL(@D306,'') + '</D306>'	+ '<D307>' + ISNULL(@D307,'') + '</D307>'
			+ '<D308>' + ISNULL(@D308,'') + '</D308>'	+ '<D309>' + ISNULL(@D309,'') + '</D309>'
			--+ '<DDCN>' + ISNULL(@DDCN,'') + '</DDCN>'	
			+ '<DXFR>' + ISNULL(@DXFR,'') + '</DXFR>'	
			+ '<EFIN>' + ISNULL(@EFIN,'') + '</EFIN>'	+ '<EMAL>' + ISNULL(@EMAL,'') + '</EMAL>'
			+ '<ERRO>' + ISNULL(@ERRO,'') + '</ERRO>'	+ '<ERRW>' + ISNULL(@ERRW,'') + '</ERRW>'
			+ '<ERCD>' + ISNULL(@ERCD,'') + '</ERCD>'	+ '<EROS>' + ISNULL(@EROS,'') + '</EROS>'
			+ '<ERRX>' + ISNULL(@ERRX,'') + '</ERRX>'
			+ '<FAXN>' + ISNULL(@FAXN,'') + '</FAXN>'	+ '<FLSH>' + '' + '</FLSH>'
			+ '<GMAL>' + ISNULL(@GMAL,'') + '</GMAL>'	+ '<GPWD>' + ISNULL(@GPWD,'') + '</GPWD>'
			--+ '<IXFR>' + ISNULL(@IXFR,'') + '</IXFR>'
			+ '<LOKF>' + ISNULL(@LOKF,'') + '</LOKF>'
			+ '<NUMB>' + ISNULL(@NUMB,'') + '</NUMB>'
			+ '<OPER>' + ISNULL(@OPER,'') + '</OPER>'	+ '<PFER>' + ISNULL(@PFER,'') + '</PFER>'
			+ '<PHON>' + ISNULL(@PHON,'') + '</PHON>'	+ '<PINR>' + '' + '</PINR>'
			+ '<RCPA>' + ISNULL(@RCPA,'') + '</RCPA>'	+ '<RCPN>' + '' + '</RCPN>'
			+ '<RCPR>' + ISNULL(@RCPR,'') + '</RCPR>'	+ '<RNH1>' + ISNULL(@RNH1,'') + '</RNH1>'
			+ '<RNH2>' + ISNULL(@RNH2,'') + '</RNH2>'	+ '<RNL1>' + ISNULL(@RNL1,'') + '</RNL1>'
			+ '<RNL2>' + ISNULL(@RNL2,'') + '</RNL2>'	+ '<RTNC>' + '' + '</RTNC>'
			+ '<SBID>' + ISNULL(@SBID,'') + '</SBID>'	+ '<SIDR>' + ISNULL(@SIDR,'') + '</SIDR>'
			+ '<SITE>' + ISNULL(@SITE,'') + '</SITE>'	+ '<STEF>' + ISNULL(@STEF,'') + '</STEF>'
			+ '<SRDQ>' + ISNULL(@SRDQ,'') + '</SRDQ>'
			+ '<TELE>' + ISNULL(@TELE,'') + '</TELE>'
			+ '<USER>' + ISNULL(@User_id,'') + '</USER>'
			+ '<VC01>' + ISNULL(@VC01,'') + '</VC01>'	+ '<VC02>' + ISNULL(@VC02,'') + '</VC02>'
			+ '<VC03>' + ISNULL(@VC03,'') + '</VC03>'	+ '<VC04>' + ISNULL(@VC04,'') + '</VC04>'
			+ '<VC05>' + ISNULL(@VC05,'') + '</VC05>'	+ '<VC06>' + ISNULL(@VC06,'') + '</VC06>'
			+ '<VC07>' + ISNULL(@VC07,'') + '</VC07>'	+ '<VC08>' + ISNULL(@VC08,'') + '</VC08>'
			+ '<VC09>' + ISNULL(@VC09,'') + '</VC09>'	+ '<VC10>' + ISNULL(@VC10,'') + '</VC10>'
			+ '<VC11>' + ISNULL(@VC11,'') + '</VC11>'	+ '<VC12>' + ISNULL(@VC12,'') + '</VC12>'
			+ '<VC13>' + ISNULL(@VC13,'') + '</VC13>'	+ '<VC14>' + ISNULL(@VC14,'') + '</VC14>'
			+ '<VC15>' + ISNULL(@VC15,'') + '</VC15>'	+ '<VC16>' + ISNULL(@VC16,'') + '</VC16>'
			+ '<VC17>' + ISNULL(@VC17,'') + '</VC17>'	+ '<VC18>' + ISNULL(@VC18,'') + '</VC18>'
			+ '<VD01>' + ISNULL(@VD01,'') + '</VD01>'	+ '<VC24>' + ISNULL(@VC24,'') + '</VC24>'
			+ '<VC25>' + ISNULL(@VC25,'') + '</VC25>'	+ '<VC26>' + ISNULL(@VC26,'') + '</VC26>'	
			+ '<VC27>' + ISNULL(@VC27,'') + '</VC27>'	+ '<VC28>' + ISNULL(@VC28,'') + '</VC28>'	
			+ '<VC29>' + ISNULL(@VC29,'') + '</VC29>'	+ '<VC30>' + ISNULL(@VC30,'') + '</VC30>'	
			+ '<VC31>' + ISNULL(@VC31,'') + '</VC31>'	+ '<VC32>' + ISNULL(@VC32,'') + '</VC32>'	
			+ '<VC33>' + ISNULL(@VC33,'') + '</VC33>'	+ '<VC34>' + ISNULL(@VC34,'') + '</VC34>'	
			+ '<VC35>' + ISNULL(@VC35,'') + '</VC35>'	+ '<VC36>' + ISNULL(@VC36,'') + '</VC36>'
			+ '<VD02>' + ISNULL(@VD02,'') + '</VD02>'	
			+ '<VD03>' + ISNULL(@VD03,'') + '</VD03>'	+ '<VD04>' + ISNULL(@VD04,'') + '</VD04>'
			+ '<USEW>' + ISNULL(@USEW,'') + '</USEW>'	+ '<WLOK>' + ISNULL(@WLOK,'') + '</WLOK>'		
			+ '<XMIT>' + ISNULL(@XMIT,'Y') + '</XMIT>'
			+ '<ZIPF>' + ISNULL(@ZIPF,'') + '</ZIPF>'
-- new for 2011
			+ '<DEBT>' + ISNULL(@DEBT,'') + '</DEBT>'	+ '<DBRE>' + ISNULL(@DBRE,'') + '</DBRE>'
			+ '<YTYF>' + ISNULL(@YTYF,'') + '</YTYF>'	+ '<VC37>' + ISNULL(@VC37,'') + '</VC37>'
			+ '<VC38>' + ISNULL(@VC38,'') + '</VC38>'
			+ '<INSC>' + ISNULL(@INSC,'') + '</INSC>'	+ '<INSV>' + ISNULL(@INSV,'') + '</INSV>'	
			+ '<STPS>' + ISNULL(@STPS,'') + '</STPS>'	+ '<STPP>' + ISNULL(@STPP,'') + '</STPP>'
			+ '<REFV>' + ISNULL(@REFV,'') + '</REFV>'   + '<APPF>' + ISNULL(@APPF,'') + '</APPF>' 
			+ '<APPA>' + ISNULL(@APPA,'') + '</APPA>'	+ '<APPC>' + ISNULL(@APPC,'') + '</APPC>' 
			+ '<APPS>' + ISNULL(@APPS,'') + '</APPS>'	+ '<APPZ>' + ISNULL(@APPZ,'') + '</APPZ>' 
			+ '<APPP>' + ISNULL(@APPP,'') + '</APPP>'	+ '<VD05>' + ISNULL(@VD05,'') + '</VD05>'
			+ '<VD07>' + ISNULL(@VD07,'') + '</VD07>'	+ '<VD08>' + ISNULL(@VD08,'') + '</VD08>'
			+ '<VD06>' + ISNULL(@VD06,'') + '</VD06>'   --+ '<CSTM>' + ISNULL(@CSTM,'') + '</CSTM>'
			+ '<MRKZ>' + ISNULL(@MRKZ,'') + '</MRKZ>'	+ '<PRPN>' + ISNULL(@PRPN,'') + '</PRPN>'
-- new for 2012
			--+ '<AAW2>' + ISNULL(@AAW2,'') + '</AAW2>'   
			+ '<TEFN>' + ISNULL(@TEFN,'') + '</TEFN>'			
-- new for 2013
			+ '<VC51>' + ISNULL(@VC51,'') + '</VC51>'	+ '<VC52>' + ISNULL(@VC52,'') + '</VC52>'
			+ '<VC40>' + ISNULL(@VC40,'') + '</VC40>'
			+ '<VC45>' + ISNULL(@VC45,'') + '</VC45>'	+ '<VC46>' + ISNULL(@VC46,'') + '</VC46>'
			+ '<VC47>' + ISNULL(Convert(Varchar(3),@VC47),'') + '</VC47>'	+ '<VC42>' + ISNULL(@VC42,'') + '</VC42>'
			+ '<VC48>' + ISNULL(@VC48,'') + '</VC48>'	+ '<VC43>' + ISNULL(@VC43,'') + '</VC43>'
			+ '<YTYS>' + ISNULL(@YTYS,'') + '</YTYS>'
-- new for 2014
			+ '<VC53>' + ISNULL(@VC53,'') + '</VC53>' + '<AUTS>' + ISNULL(@AUTS,'') + '</AUTS>'
			+ '<ASAV>' + ISNULL(@ASAV,'') + '</ASAV>' + '<GMTC>' + ISNULL(@GMTC,'') + '</GMTC>'
			+ '<VC19>' + ISNULL(@VC19,'') + '</VC19>' + '<VC20>' + ISNULL(@VC20,'') + '</VC20>'
			+ '<VC21>' + ISNULL(@VC21,'') + '</VC21>' + '<VC49>' + ISNULL(@VC49,'') + '</VC49>'
			+ '<VC50>' + ISNULL(@VC50,'') + '</VC50>' + '<VC22>' + ISNULL(@VC22,'') + '</VC22>'
			+ '<VC23>' + ISNULL(@VC23,'') + '</VC23>' + '<VC39>' + ISNULL(@VC39,'') + '</VC39>'
			+ '<VC41>' + ISNULL(@VC41,'') + '</VC41>' + '<VC44>' + ISNULL(@VC44,'') + '</VC44>'
			+ '<D310>' + ISNULL(@D310,'') + '</D310>'
			+ '<VC54>' + ISNULL(@VC54,'') + '</VC54>' + '<VC55>' + ISNULL(@VC55,'') + '</VC55>'
			+ '<VC56>' + ISNULL(@VC56,'') + '</VC56>' + '<EICX>' + ISNULL(@EICX,'') + '</EICX>'
-- new for 2015

			--+ '<CST1>' + ISNULL(@CST1,'') + '</CST1>' + '<CST2>' + ISNULL(@CST2,'') + '</CST2>'
			--+ '<CST3>' + ISNULL(@CST3,'') + '</CST3>' + '<CST4>' + ISNULL(@CST4,'') + '</CST4>'
			--+ '<CST5>' + ISNULL(@CST5,'') + '</CST5>' + '<CST6>' + ISNULL(@CST6,'') + '</CST6>'
			--+ '<CST7>' + ISNULL(@CST7,'') + '</CST7>' + '<CST8>' + ISNULL(@CST8,'') + '</CST8>'
			--+ '<CST9>' + ISNULL(@CST9,'') + '</CST9>'

			+ '<USST>' + ISNULL(@USST,'') + '</USST>'
			+ '<VFSK>' + ISNULL(@VFSK,'') + '</VFSK>' + '<YTYP>' + ISNULL(@YTYP,'') + '</YTYP>'
			+ '<VC57>' + ISNULL(@VC57,'') + '</VC57>'
			+ '<VC58>' + ISNULL(@VC58,'') + '</VC58>' + '<VD09>' + ISNULL(convert(varchar(10), @VD09),'') + '</VD09>'
			+ '<RTPD>' + ISNULL(@RTPD,'') + '</RTPD>'
			
-- new for 2016

			-- ticketid 82094
			-- + '<RTLT>' + ISNULL(@RTLT,'') + '</RTLT>' 
			+ '<SBLW>' + ISNULL(@SBLW,'') + '</SBLW>'
			+ '<PDP2>' + ISNULL(@PDP2,'') + '</PDP2>' + '<MSKA>' + ISNULL(@MSKA,'') + '</MSKA>'
			+ '<MNUW>' + ISNULL(@MNUW,'') + '</MNUW>' + '<VC59>' + ISNULL(@VC59,'') + '</VC59>'
			+ '<VD59>' + ISNULL(convert(varchar(10), @VD59),'') + '</VD59>' + '<RLIX>' + ISNULL(@RLIX,'') + '</RLIX>'
			+ '<RLIM>' + ISNULL(convert(varchar(10), @RLIM),'') + '</RLIM>'

-- new for 2017
			+ '<KEYT>' + ISNULL(@KEYT,'') + '</KEYT>' + '<VC61>' + ISNULL(@VC61,'') + '</VC61>' 
			+ '<VC60>' + ISNULL(@VC60,'') + '</VC60>' + '<MKID>' + ISNULL(@MKID,'') + '</MKID>'
			+ '<NBKS>' + ISNULL(@NBKS,'') + '</NBKS>' + '<CPCI>' + ISNULL(@CPCI,'') + '</CPCI>'

-- new for 2018
			+ '<VC65>' + ISNULL(@VC65,'') + '</VC65>' + '<VD10>' + ISNULL(convert(varchar(10), @VD10),'') + '</VD10>' 
			+ '<VC62>' + ISNULL(@VC62,'') + '</VC62>' + '<VC63>' + ISNULL(@VC63,'') + '</VC63>'
			+ '<VC64>' + ISNULL(@VC64,'') + '</VC64>' + '<FPDT>' + ISNULL(@FPDT,'') + '</FPDT>'
-- new for 2019
			+ '<AASH>' + ISNULL(@AASH,'') + '</AASH>' + '<EROB>' + ISNULL(@EROB,'') + '</EROB>' 
			+ '<ERCB>' + ISNULL(@ERCB,'') + '</ERCB>' + '<VC68>' + ISNULL(@VC68,'') + '</VC68>' 
			+ '<ERCR>' + ISNULL(@ERCR,'') + '</ERCR>' + '<YTYB>' + ISNULL(@YTYB,'') + '</YTYB>' 
			+ '<EPMT>' + ISNULL(@EPMT,'') + '</EPMT>' 
			+ '<VC67>' + ISNULL(@VC67,'') + '</VC67>' + '<VD67>' + ISNULL(convert(varchar(10),@VD67),'') + '</VD67>'
-- new for 2020
			+ '<VC70>' + ISNULL(@VC70,'') + '</VC70>' + '<VC71>' + ISNULL(@VC71,'') + '</VC71>' 
			+ '<CPCH>' + ISNULL(@CPCH,'') + '</CPCH>' + '<EMAM>' + ISNULL(@EMAM,'') + '</EMAM>' 
			+ '<IMTC>' + ISNULL(@IMTC,'') + '</IMTC>' + '<WA03>' + ISNULL(@WA03,'') + '</WA03>' 
			+ '<WB03>' + ISNULL(@WB03,'') + '</WB03>' + '<WA04>' + ISNULL(@WA04,'') + '</WA04>' 
			+ '<WB04>' + ISNULL(@WB04,'') + '</WB04>' + '<WA05>' + ISNULL(@WA05,'') + '</WA05>' 
			+ '<WB05>' + ISNULL(@WB05,'') + '</WB05>' + '<ERC1>' + ISNULL(@ERC1,'') + '</ERC1>'
			--+ '<XFLT>' + ISNULL(@XFLT,'') + '</XFLT>' 
      + '<VC72>' + ISNULL(@VC72,'') + '</VC72>' 
-- new for 2021
      + '<VC69>' + ISNULL(@VC69,'') + '</VC69>' + '<VC73>' + ISNULL(@VC73,'') + '</VC73>' 
      + '<VC77>' + ISNULL(@VC77,'') + '</VC77>' 
      + '<VC74>' + ISNULL(@VC74,'') + '</VC74>' + '<VC75>' + ISNULL(@VC75,'') + '</VC75>' 
      + '<VC76>' + ISNULL(@VC76,'') + '</VC76>' 
			
	IF (@BILL <> '499') SELECT @XMLString = @XMLString + '<BILL>I' + ISNULL(@BILL,'') + '</BILL>'
	IF (@BILL IS NULL) SELECT @XMLString = @XMLString + '<BILL/>'
	IF (@BILC <> '498') SELECT @XMLString = @XMLString + '<BILC>C' + ISNULL(@BILL,'') + '</BILC>'
	IF (@BILC IS NULL) SELECT @XMLString = @XMLString + '<BILC/>'

	If @add_print_settings = 1
	Begin
			SELECT @XMLString = @XMLString
			+ '<CHKT>' + ISNULL(Convert(Varchar(2),@CHKT),'') + '</CHKT>'	+ '<CHKS>' + ISNULL(@CHKS,'') + '</CHKS>'
			+ '<TEP1>' + ISNULL(Convert(char(1),@TEP1),'') + '</TEP1>'	+ '<TEP2>' + ISNULL(Convert(char(1),@TEP2),'') + '</TEP2>'
			+ '<TEP3>' + ISNULL(Convert(char(1),@TEP3),'') + '</TEP3>'	+ '<TEP4>' + ISNULL(Convert(char(1),@TEP4),'') + '</TEP4>'

			+ '<CDS1>' + ISNULL(@CDS1,'') + '</CDS1>'	+ '<LBE1>' + ISNULL(@LBE1,'') + '</LBE1>'
			+ '<LBE2>' + ISNULL(@LBE2,'') + '</LBE2>'	+ '<LBF1>' + ISNULL(@LBF1,'') + '</LBF1>'
			+ '<LBF2>' + ISNULL(@LBF2,'') + '</LBF2>'	+ '<LPA1>' + ISNULL(@LPA1,'') + '</LPA1>'
			+ '<LPB1>' + ISNULL(@LPB1,'') + '</LPB1>'	+ '<LPA2>' + ISNULL(@LPA2,'') + '</LPA2>'
			+ '<LPA3>' + ISNULL(@LPA3,'') + '</LPA3>'	+ '<LPB3>' + ISNULL(@LPB3,'') + '</LPB3>'
			+ '<LTCA>' + ISNULL(@LTCA,'') + '</LTCA>'	+ '<LTCB>' + ISNULL(@LTCB,'') + '</LTCB>'
			+ '<LTSA>' + ISNULL(@LTSA,'') + '</LTSA>'	+ '<LTSB>' + ISNULL(@LTSB,'') + '</LTSB>'
			+ '<LPA4>' + ISNULL(@LPA4,'') + '</LPA4>'	+ '<LPB4>' + ISNULL(@LPB4,'') + '</LPB4>'
			+ '<LPA5>' + ISNULL(@LPA5,'') + '</LPA5>'	+ '<LPB5>' + ISNULL(@LPB5,'') + '</LPB5>'
			+ '<LPA6>' + ISNULL(@LPA6,'') + '</LPA6>'	+ '<LPB6>' + ISNULL(@LPB6,'') + '</LPB6>'
			+ '<LPA7>' + ISNULL(@LPA7,'') + '</LPA7>'	+ '<LPB7>' + ISNULL(@LPB7,'') + '</LPB7>'
			+ '<LPC7>' + ISNULL(@LPC7,'') + '</LPC7>'	+ '<LPD7>' + ISNULL(@LPD7,'') + '</LPD7>'
			+ '<LPA8>' + ISNULL(@LPA8,'') + '</LPA8>'	+ '<LPB8>' + ISNULL(@LPB8,'') + '</LPB8>'
			+ '<LPC8>' + ISNULL(@LPC8,'') + '</LPC8>'	+ '<LPD8>' + ISNULL(@LPD8,'') + '</LPD8>'
			+ '<LMDA>' + ISNULL(@LMDA,'') + '</LMDA>'	+ '<LMDB>' + ISNULL(@LMDB,'') + '</LMDB>'
			+ '<LPTA>' + ISNULL(@LPTA,'') + '</LPTA>'	+ '<LPTB>' + ISNULL(@LPTB,'') + '</LPTB>'
			+ '<LPSA>' + ISNULL(@LPSA,'') + '</LPSA>'	+ '<LPSB>' + ISNULL(@LPSB,'') + '</LPSB>'
			+ '<LPCO>' + ISNULL(@LPCO,'') + '</LPCO>'	+ '<LPCP>' + ISNULL(@LPCP,'') + '</LPCP>'
			+ '<LPWB>' + ISNULL(@LPWB,'') + '</LPWB>'	+ '<LPA9>' + ISNULL(@LPA9,'') + '</LPA9>'
			+ '<LPB9>' + ISNULL(@LPB9,'') + '</LPB9>'	+ '<LPC9>' + ISNULL(@LPC9,'') + '</LPC9>'
			+ '<LPD9>' + ISNULL(@LPD9,'') + '</LPD9>'	+ '<LPE9>' + ISNULL(@LPE9,'') + '</LPE9>'
			+ '<LPBA>' + ISNULL(@LPBA,'') + '</LPBA>'
			+ '<LPCA>' + ISNULL(@LPCA,'') + '</LPCA>'	+ '<LPDA>' + ISNULL(@LPDA,'') + '</LPDA>'
			+ '<LPEA>' + ISNULL(@LPEA,'') + '</LPEA>'

			+ '<LSRD>' + ISNULL(@LSRD,'') + '</LSRD>'	+ '<LSRO>' + ISNULL(@LSRO,'') + '</LSRO>'
			+ '<LSRS>' + ISNULL(@LSRS,'') + '</LSRS>'
			+ '<ESFP>' + ISNULL(@ESFP,'') + '</ESFP>'	+ '<LSRW>' + ISNULL(@LSRW,'') + '</LSRW>'
			+ '<LPSC>' + ISNULL(@LPSC,'') + '</LPSC>'	+ '<LPSN>' + ISNULL(@LPSN,'') + '</LPSN>'
			+ '<LSRV>' + ISNULL(@LSRV,'') + '</LSRV>'	+ '<LPSI>' + ISNULL(@LPSI,'') + '</LPSI>'
			+ '<BOLD>' + ISNULL(@BOLD,'') + '</BOLD>'	+ '<LPSP>' + ISNULL(@LPSP,'') + '</LPSP>'
			+ '<IDUE>' + ISNULL(@IDUE,'') + '</IDUE>'	+ '<TSBD>' + ISNULL(@TSBD,'') + '</TSBD>'
			+ '<EXPF>' + ISNULL(@EXPF,'') + '</EXPF>'	+ '<SBLK>' + ISNULL(@SBLK,'') + '</SBLK>'
			+ '<BDPO>' + ISNULL(@BDPO,'') + '</BDPO>'	+ '<MSSN>' + ISNULL(@MSSN,'') + '</MSSN>'
			+ '<ITMZ>' + ISNULL(@ITMZ,'') + '</ITMZ>'	+ '<LPVA>' + ISNULL(@LPVA,'') + '</LPVA>'
			+ '<INV2>' + ISNULL(@INV2,'') + '</INV2>'

			+ '<CCD1>' + ISNULL(@CCD1,'') + '</CCD1>'	+ '<CPA1>' + ISNULL(@CPA1,'') + '</CPA1>'
			+ '<CPB1>' + ISNULL(@CPB1,'') + '</CPB1>'	+ '<CPK1>' + ISNULL(@CPK1,'') + '</CPK1>'
			+ '<CPK2>' + ISNULL(@CPK2,'') + '</CPK2>'	+ '<CPA2>' + ISNULL(@CPA2,'') + '</CPA2>'
			+ '<CPA3>' + ISNULL(@CPA3,'') + '</CPA3>'	+ '<CPB3>' + ISNULL(@CPB3,'') + '</CPB3>'
			+ '<CPA5>' + ISNULL(@CPA5,'') + '</CPA5>'	+ '<CPB5>' + ISNULL(@CPB5,'') + '</CPB5>'
			+ '<CPA6>' + ISNULL(@CPA6,'') + '</CPA6>'	+ '<CPB6>' + ISNULL(@CPB6,'') + '</CPB6>'
			+ '<CPA7>' + ISNULL(@CPA7,'') + '</CPA7>'	+ '<CPB7>' + ISNULL(@CPB7,'') + '</CPB7>'
			+ '<CPC7>' + ISNULL(@CPC7,'') + '</CPC7>'	+ '<CPD7>' + ISNULL(@CPD7,'') + '</CPD7>'
			+ '<CPA8>' + ISNULL(@CPA8,'') + '</CPA8>'	+ '<CPB8>' + ISNULL(@CPB8,'') + '</CPB8>'
			+ '<CPC8>' + ISNULL(@CPC8,'') + '</CPC8>'	+ '<CPD8>' + ISNULL(@CPD8,'') + '</CPD8>'
			+ '<CMDA>' + ISNULL(@CMDA,'') + '</CMDA>'	+ '<CMDB>' + ISNULL(@CMDB,'') + '</CMDB>'
			+ '<CPTA>' + ISNULL(@CPTA,'') + '</CPTA>'	+ '<CPTB>' + ISNULL(@CPTB,'') + '</CPTB>'
			+ '<CPWB>' + ISNULL(@CPWB,'') + '</CPWB>'	+ '<CPA9>' + ISNULL(@CPA9,'') + '</CPA9>'
			+ '<CPB9>' + ISNULL(@CPB9,'') + '</CPB9>'	+ '<CPC9>' + ISNULL(@CPC9,'') + '</CPC9>'
			+ '<CPD9>' + ISNULL(@CPD9,'') + '</CPD9>'	+ '<CPE9>' + ISNULL(@CPE9,'') + '</CPE9>'
			+ '<CPBA>' + ISNULL(@CPBA,'') + '</CPBA>'
			+ '<CPCA>' + ISNULL(@CPCA,'') + '</CPCA>'	+ '<CPDA>' + ISNULL(@CPDA,'') + '</CPDA>'
			+ '<CPEA>' + ISNULL(@CPEA,'') + '</CPEA>'	+ '<LPRB>' + ISNULL(@LPRB,'') + '</LPRB>'
			+ '<ISSP>' + ISNULL(@ISSP,'') + '</ISSP>'   + '<AUTN>' + ISNULL(@ISSP,'') + '</AUTN>'
-- new for 2015
			+ '<PRVX>' + ISNULL(@PRVX,'') + '</PRVX>' + '<INEF>' + ISNULL(@INEF,'') + '</INEF>'
			+ '<LPF7>' + ISNULL(@LPF7,'') + '</LPF7>' + '<LPE7>' + ISNULL(@LPE7,'') + '</LPE7>'
			+ '<LPD1>' + ISNULL(@LPD1,'') + '</LPD1>' + '<LPC1>' + ISNULL(@LPC1,'') + '</LPC1>'
			+ '<MPTN>' + ISNULL(@MPTN,'') + '</MPTN>' + '<CPD1>' + ISNULL(@CPD1,'') + '</CPD1>'
			+ '<CPC1>' + ISNULL(@CPC1,'') + '</CPC1>' + '<CPA4>' + ISNULL(@CPA4,'') + '</CPA4>'
			+ '<CPB4>' + ISNULL(@CPB4,'') + '</CPB4>' + '<RFAM>' + ISNULL(Convert(varchar(15),@RFAM),'') + '</RFAM>'
			+ '<PMTV>' + ISNULL(@PMTV,'') + '</PMTV>' + '<RFEX>' + ISNULL(@RFEX,'') + '</RFEX>'
-- new for 2017
			+ '<LPAB>' + ISNULL(@LPAB,'') + '</LPAB>' + '<LPBB>' + ISNULL(@LPBB,'') + '</LPBB>' 
			+ '<LPAM>' + ISNULL(@LPAM,'') + '</LPAM>' + '<LPBM>' + ISNULL(@LPBM,'') + '</LPBM>' 
			+ '<LPCM>' + ISNULL(@LPCM,'') + '</LPCM>' + '<LPDM>' + ISNULL(@LPDM,'') + '</LPDM>' 
			+ '<LPEM>' + ISNULL(@LPEM,'') + '</LPEM>' + '<CPAM>' + ISNULL(@CPAM,'') + '</CPAM>' 
			+ '<CPBM>' + ISNULL(@CPBM,'') + '</CPBM>' + '<CPCM>' + ISNULL(@CPCM,'') + '</CPCM>' 
			+ '<CPDM>' + ISNULL(@CPDM,'') + '</CPDM>' + '<CPEM>' + ISNULL(@CPEM,'') + '</CPEM>' 
			+ '<MEIN>' + ISNULL(@MEIN,'') + '</MEIN>' + '<MRTN>' + ISNULL(@MRTN,'') + '</MRTN>'
-- new for 2018
			+ '<LSES>' + ISNULL(@LSES,'') + '</LSES>' + '<LPA0>' + ISNULL(@LPA0,'') + '</LPA0>'
-- new for 2020			
			+ '<LACA>' + ISNULL(@LACA,'') + '</LACA>' + '<LACB>' + ISNULL(@LACB,'') + '</LACB>' 
			+ '<PFBA>' + ISNULL(@PFBA,'') + '</PFBA>' + '<PFBB>' + ISNULL(@PFBB,'') + '</PFBB>' 
-- new for 2021
      + '<LPB0>' + ISNULL(@LPB0,'') + '</LPB0>' 
      + '<LPAC>' + ISNULL(@LPAC,'') + '</LPAC>' + '<LPBC>' + ISNULL(@LPBC,'') + '</LPBC>' 
      + '<CPAC>' + ISNULL(@CPAC,'') + '</CPAC>' + '<CPBC>' + ISNULL(@CPBC,'') + '</CPBC>' 
      + isnull(@print_order,'')
	END
END
ELSE
BEGIN
	DECLARE cur_rs CURSOR
	FOR
SELECT tblXlinkXMLDataForPublish.XMLTag, XMLData
FROM tblXlinkXMLDataForPublish 
INNER JOIN 
        (SELECT XMLTag, MAX(rowID) RowID 
        FROM tblXlinkXMLDataForPublish 
        WHERE user_id = @user_id AND Published = 0 
        and isnull(franchiseuser_id, 0) = @Franchiseuserid
        and account = @account
        and tablename = 'tblXlinkOfficeSetup'
        GROUP BY XMLTag) AS #LastXMLTag ON #LastXMLTag.RowID = tblXlinkXMLDataForPublish.RowID
        order by tblXlinkXMLDataForPublish.RowID
		   
	OPEN cur_rs;
	FETCH NEXT FROM cur_rs INTO @XMLTag, @XMLData;
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
		IF (@@FETCH_STATUS <> -2)
			BEGIN   
			IF @XMLTag = 'ERRX'
				BEGIN
					SELECT @XMLData = CASE @XMLData
						WHEN 'F' THEN '0'
						WHEN 'E' THEN '1'
						WHEN 'A' THEN 'X'
						ELSE ''
					END;
				END;
			IF @XMLTag = '1040' SELECT @XMLTag = '_0x0031_040'
			select @XMLString = @XMLString + '<' + @XMLTag + '>' + @XMLData + '</' + @XMLTag + '>';
			END;
		FETCH NEXT FROM cur_rs INTO @XMLTag, @XMLData;
	END;
	CLOSE cur_rs;
	DEALLOCATE cur_rs;
	SELECT @XMLString = @XMLString 
			--+ '<CSTM>' + ISNULL(@CSTM,'') + '</CSTM>'
			--+ '<CST1>' + ISNULL(@CST1,'') + '</CST1>'
			--+ '<CST2>' + ISNULL(@CST2,'') + '</CST2>'
			--+ '<CST3>' + ISNULL(@CST3,'') + '</CST3>'
			--+ '<CST4>' + ISNULL(@CST4,'') + '</CST4>'
			--+ '<CST5>' + ISNULL(@CST5,'') + '</CST5>'
			--+ '<CST6>' + ISNULL(@CST6,'') + '</CST6>'
			--+ '<CST7>' + ISNULL(@CST7,'') + '</CST7>'
			--+ '<CST8>' + ISNULL(@CST8,'') + '</CST8>'
			--+ '<CST9>' + ISNULL(@CST9,'') + '</CST9>'
			+ '<OFID>' + ISNULL(@OFID,'') + '</OFID>'
			+ '<XMIT>' + ISNULL(@XMIT,'Y') + '</XMIT>'
			+ '<OPER>' + ISNULL(@OPER,'') + '</OPER>'			
			+ '<PHON>' + ISNULL(@PHON,'') + '</PHON>'
			+ '<ADDR>' + ISNULL(@ADDR,'') + '</ADDR>'
			+ '<FAXN>' + ISNULL(@FAXN,'') + '</FAXN>'
			+ '<EMAL>' + ISNULL(@EMAL,'') + '</EMAL>'
		IF (@BILL <> '499') SELECT @XMLString = @XMLString + '<BILL>I' + ISNULL(@BILL,'') + '</BILL>'
		IF (@BILL IS NULL) SELECT @XMLString = @XMLString + '<BILL/>'
		IF (@BILC <> '498') SELECT @XMLString = @XMLString + '<BILC>C' + ISNULL(@BILC,'') + '</BILC>'
		IF (@BILC IS NULL) SELECT @XMLString = @XMLString + '<BILC/>'
END;

SELECT @XMLString = @XMLString + @XMLString3 + @XMLCSTString + @OutString + '</xmldata>'

select CONVERT(varchar(max), @XMLString)

    IF @seqno = 1
		BEGIN
			SELECT @XMLStringLaunch = '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>'
			INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLStringLaunch)
			SELECT @seqno = 2
		END		

	INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno, @XMLString)

-- Begin printer override section to add second XML record
	If @add_print_settings = 1 AND @override_print_settings = 1
	Begin
		SELECT @XMLString = '<xmldata><cmnd>Global</cmnd>' + @XMLString2 -- + '<ADIP>' + ISNULL(@ADIP, '')  +  '</ADIP><AUDF>' + ISNULL(@AUDF,'') + '</AUDF><AUDN>' + ISNULL(@AUDN,'') + '</AUDN><ACAD>' + ISNULL(@ACAD,'') + '</ACAD>'
		SELECT @XMLString = @XMLString
		+ '<CHKT>' + ISNULL(Convert(Varchar(2),@CHKT),'') + '</CHKT>'	+ '<CHKS>' + ISNULL(@CHKS,'') + '</CHKS>'
		+ '<TEP1>' + ISNULL(Convert(char(1),@TEP1),'') + '</TEP1>'	+ '<TEP2>' + ISNULL(Convert(char(1),@TEP2),'') + '</TEP2>'
		+ '<TEP3>' + ISNULL(Convert(char(1),@TEP3),'') + '</TEP3>'	+ '<TEP4>' + ISNULL(Convert(char(1),@TEP4),'') + '</TEP4>'

		+ '<CDS1>' + ISNULL(@CDS1,'') + '</CDS1>'	+ '<LBE1>' + ISNULL(@LBE1,'') + '</LBE1>'
		+ '<LBE2>' + ISNULL(@LBE2,'') + '</LBE2>'	+ '<LBF1>' + ISNULL(@LBF1,'') + '</LBF1>'
		+ '<LBF2>' + ISNULL(@LBF2,'') + '</LBF2>'	+ '<LPA1>' + ISNULL(@LPA1,'') + '</LPA1>'
		+ '<LPB1>' + ISNULL(@LPB1,'') + '</LPB1>'	+ '<LPA2>' + ISNULL(@LPA2,'') + '</LPA2>'
		+ '<LPA3>' + ISNULL(@LPA3,'') + '</LPA3>'	+ '<LPB3>' + ISNULL(@LPB3,'') + '</LPB3>'
		+ '<LTCA>' + ISNULL(@LTCA,'') + '</LTCA>'	+ '<LTCB>' + ISNULL(@LTCB,'') + '</LTCB>'
		+ '<LTSA>' + ISNULL(@LTSA,'') + '</LTSA>'	+ '<LTSB>' + ISNULL(@LTSB,'') + '</LTSB>'
		+ '<LPA4>' + ISNULL(@LPA4,'') + '</LPA4>'	+ '<LPB4>' + ISNULL(@LPB4,'') + '</LPB4>'
		+ '<LPA5>' + ISNULL(@LPA5,'') + '</LPA5>'	+ '<LPB5>' + ISNULL(@LPB5,'') + '</LPB5>'
		+ '<LPA6>' + ISNULL(@LPA6,'') + '</LPA6>'	+ '<LPB6>' + ISNULL(@LPB6,'') + '</LPB6>'
		+ '<LPA7>' + ISNULL(@LPA7,'') + '</LPA7>'	+ '<LPB7>' + ISNULL(@LPB7,'') + '</LPB7>'
		+ '<LPC7>' + ISNULL(@LPC7,'') + '</LPC7>'	+ '<LPD7>' + ISNULL(@LPD7,'') + '</LPD7>'
		+ '<LPA8>' + ISNULL(@LPA8,'') + '</LPA8>'	+ '<LPB8>' + ISNULL(@LPB8,'') + '</LPB8>'
		+ '<LPC8>' + ISNULL(@LPC8,'') + '</LPC8>'	+ '<LPD8>' + ISNULL(@LPD8,'') + '</LPD8>'
		+ '<LMDA>' + ISNULL(@LMDA,'') + '</LMDA>'	+ '<LMDB>' + ISNULL(@LMDB,'') + '</LMDB>'
		+ '<LPTA>' + ISNULL(@LPTA,'') + '</LPTA>'	+ '<LPTB>' + ISNULL(@LPTB,'') + '</LPTB>'
		+ '<LPSA>' + ISNULL(@LPSA,'') + '</LPSA>'	+ '<LPSB>' + ISNULL(@LPSB,'') + '</LPSB>'
		+ '<LPCO>' + ISNULL(@LPCO,'') + '</LPCO>'	+ '<LPCP>' + ISNULL(@LPCP,'') + '</LPCP>'
		+ '<LPWB>' + ISNULL(@LPWB,'') + '</LPWB>'	+ '<LPA9>' + ISNULL(@LPA9,'') + '</LPA9>'
		+ '<LPB9>' + ISNULL(@LPB9,'') + '</LPB9>'	+ '<LPC9>' + ISNULL(@LPC9,'') + '</LPC9>'
		+ '<LPD9>' + ISNULL(@LPD9,'') + '</LPD9>'	+ '<LPE9>' + ISNULL(@LPE9,'') + '</LPE9>'
		+ '<LPBA>' + ISNULL(@LPBA,'') + '</LPBA>'
		+ '<LPCA>' + ISNULL(@LPCA,'') + '</LPCA>'	+ '<LPDA>' + ISNULL(@LPDA,'') + '</LPDA>'
		+ '<LPEA>' + ISNULL(@LPEA,'') + '</LPEA>'

		+ '<LSRD>' + ISNULL(@LSRD,'') + '</LSRD>'	+ '<LSRO>' + ISNULL(@LSRO,'') + '</LSRO>'
		+ '<LSRS>' + ISNULL(@LSRS,'') + '</LSRS>'
		+ '<ESFP>' + ISNULL(@ESFP,'') + '</ESFP>'	+ '<LSRW>' + ISNULL(@LSRW,'') + '</LSRW>'
		+ '<LPSC>' + ISNULL(@LPSC,'') + '</LPSC>'	+ '<LPSN>' + ISNULL(@LPSN,'') + '</LPSN>'
		+ '<LSRV>' + ISNULL(@LSRV,'') + '</LSRV>'	+ '<LPSI>' + ISNULL(@LPSI,'') + '</LPSI>'
		+ '<BOLD>' + ISNULL(@BOLD,'') + '</BOLD>'	+ '<LPSP>' + ISNULL(@LPSP,'') + '</LPSP>'
		+ '<IDUE>' + ISNULL(@IDUE,'') + '</IDUE>'	+ '<TSBD>' + ISNULL(@TSBD,'') + '</TSBD>'
		+ '<EXPF>' + ISNULL(@EXPF,'') + '</EXPF>'	+ '<SBLK>' + ISNULL(@SBLK,'') + '</SBLK>'
		+ '<BDPO>' + ISNULL(@BDPO,'') + '</BDPO>'	+ '<MSSN>' + ISNULL(@MSSN,'') + '</MSSN>'
		+ '<ITMZ>' + ISNULL(@ITMZ,'') + '</ITMZ>'	+ '<LPVA>' + ISNULL(@LPVA,'') + '</LPVA>'
		+ '<INV2>' + ISNULL(@INV2,'') + '</INV2>'

		+ '<CCD1>' + ISNULL(@CCD1,'') + '</CCD1>'	+ '<CPA1>' + ISNULL(@CPA1,'') + '</CPA1>'
		+ '<CPB1>' + ISNULL(@CPB1,'') + '</CPB1>'	+ '<CPK1>' + ISNULL(@CPK1,'') + '</CPK1>'
		+ '<CPK2>' + ISNULL(@CPK2,'') + '</CPK2>'	+ '<CPA2>' + ISNULL(@CPA2,'') + '</CPA2>'
		+ '<CPA3>' + ISNULL(@CPA3,'') + '</CPA3>'	+ '<CPB3>' + ISNULL(@CPB3,'') + '</CPB3>'
		+ '<CPA5>' + ISNULL(@CPA5,'') + '</CPA5>'	+ '<CPB5>' + ISNULL(@CPB5,'') + '</CPB5>'
		+ '<CPA6>' + ISNULL(@CPA6,'') + '</CPA6>'	+ '<CPB6>' + ISNULL(@CPB6,'') + '</CPB6>'
		+ '<CPA7>' + ISNULL(@CPA7,'') + '</CPA7>'	+ '<CPB7>' + ISNULL(@CPB7,'') + '</CPB7>'
		+ '<CPC7>' + ISNULL(@CPC7,'') + '</CPC7>'	+ '<CPD7>' + ISNULL(@CPD7,'') + '</CPD7>'
		+ '<CPA8>' + ISNULL(@CPA8,'') + '</CPA8>'	+ '<CPB8>' + ISNULL(@CPB8,'') + '</CPB8>'
		+ '<CPC8>' + ISNULL(@CPC8,'') + '</CPC8>'	+ '<CPD8>' + ISNULL(@CPD8,'') + '</CPD8>'
		+ '<CMDA>' + ISNULL(@CMDA,'') + '</CMDA>'	+ '<CMDB>' + ISNULL(@CMDB,'') + '</CMDB>'
		+ '<CPTA>' + ISNULL(@CPTA,'') + '</CPTA>'	+ '<CPTB>' + ISNULL(@CPTB,'') + '</CPTB>'
		+ '<CPWB>' + ISNULL(@CPWB,'') + '</CPWB>'	+ '<CPA9>' + ISNULL(@CPA9,'') + '</CPA9>'
		+ '<CPB9>' + ISNULL(@CPB9,'') + '</CPB9>'	+ '<CPC9>' + ISNULL(@CPC9,'') + '</CPC9>'
		+ '<CPD9>' + ISNULL(@CPD9,'') + '</CPD9>'	+ '<CPE9>' + ISNULL(@CPE9,'') + '</CPE9>'
		+ '<CPBA>' + ISNULL(@CPBA,'') + '</CPBA>'
		+ '<CPCA>' + ISNULL(@CPCA,'') + '</CPCA>'	+ '<CPDA>' + ISNULL(@CPDA,'') + '</CPDA>'
		+ '<CPEA>' + ISNULL(@CPEA,'') + '</CPEA>'	+ '<LPRB>' + ISNULL(@LPRB,'') + '</LPRB>'
		+ '<ISSP>' + ISNULL(@ISSP,'') + '</ISSP>'   + '<AUTN>' + ISNULL(@CPEA,'') + '</AUTN>'	
-- new for 2015
		+ '<PRVX>' + ISNULL(@PRVX,'') + '</PRVX>' + '<INEF>' + ISNULL(@INEF,'') + '</INEF>'
		+ '<LPF7>' + ISNULL(@LPF7,'') + '</LPF7>' + '<LPE7>' + ISNULL(@LPE7,'') + '</LPE7>'
		+ '<LPD1>' + ISNULL(@LPD1,'') + '</LPD1>' + '<LPC1>' + ISNULL(@LPC1,'') + '</LPC1>'
		+ '<MPTN>' + ISNULL(@MPTN,'') + '</MPTN>' + '<CPD1>' + ISNULL(@CPD1,'') + '</CPD1>'
		+ '<CPC1>' + ISNULL(@CPC1,'') + '</CPC1>' + '<CPA4>' + ISNULL(@CPA4,'') + '</CPA4>'
		+ '<CPB4>' + ISNULL(@CPB4,'') + '</CPB4>' + '<RFAM>' + ISNULL(Convert(varchar(15),@RFAM),'') + '</RFAM>'
		+ '<PMTV>' + ISNULL(@PMTV,'') + '</PMTV>' + '<RFEX>' + ISNULL(@RFEX,'') + '</RFEX>'
-- new for 2017
		+ '<LPAB>' + ISNULL(@LPAB,'') + '</LPAB>' + '<LPBB>' + ISNULL(@LPBB,'') + '</LPBB>' 
		+ '<LPAM>' + ISNULL(@LPAM,'') + '</LPAM>' + '<LPBM>' + ISNULL(@LPBM,'') + '</LPBM>' 
		+ '<LPCM>' + ISNULL(@LPCM,'') + '</LPCM>' + '<LPDM>' + ISNULL(@LPDM,'') + '</LPDM>' 
		+ '<LPEM>' + ISNULL(@LPEM,'') + '</LPEM>' + '<CPAM>' + ISNULL(@CPAM,'') + '</CPAM>' 
		+ '<CPBM>' + ISNULL(@CPBM,'') + '</CPBM>' + '<CPCM>' + ISNULL(@CPCM,'') + '</CPCM>' 
		+ '<CPDM>' + ISNULL(@CPDM,'') + '</CPDM>' + '<CPEM>' + ISNULL(@CPEM,'') + '</CPEM>' 
		+ '<MEIN>' + ISNULL(@MEIN,'') + '</MEIN>' + '<MRTN>' + ISNULL(@MRTN,'') + '</MRTN>'
-- new for 2018
			+ '<LSES>' + ISNULL(@LSES,'') + '</LSES>' + '<LPA0>' + ISNULL(@LPA0,'') + '</LPA0>'
-- new for 2020			
			+ '<LACA>' + ISNULL(@LACA,'') + '</LACA>' + '<LACB>' + ISNULL(@LACB,'') + '</LACB>' 
			+ '<PFBA>' + ISNULL(@PFBA,'') + '</PFBA>' + '<PFBB>' + ISNULL(@PFBB,'') + '</PFBB>' 
-- new for 2021
      + '<LPB0>' + ISNULL(@LPB0,'') + '</LPB0>' 
      + '<LPAC>' + ISNULL(@LPAC,'') + '</LPAC>' + '<LPBC>' + ISNULL(@LPBC,'') + '</LPBC>' 
      + '<CPAC>' + ISNULL(@CPAC,'') + '</CPAC>' + '<CPBC>' + ISNULL(@CPBC,'') + '</CPBC>' 
      + isnull(@print_order,'')

		SELECT @XMLString = @XMLString + @XMLString3 + '</xmldata>'
		SELECT @seqno = @seqno + 1
		INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno, @XMLString)
	END
-- End printer override section
	
	UPDATE tblXlinkOfficeSetup SET publish_date = getdate(), override_print_settings = 0 where user_id = @user_id
	
	UPDATE tblXlinkXMLDataForPublish SET Published = 1
        WHERE user_id = @user_id AND Published = 0 
        AND isnull(franchiseuser_id, 0) = @Franchiseuserid
        AND account = @account
        AND tablename = 'tblXlinkOfficeSetup'

	If RTrim(@user_id) = RTrim(@masterUser)
	BEGIN
		SET @masterUser = '0'
	END

	If RTrim(@user_id) = RTrim(@Franchiseuserid)
	BEGIN
		SET @Franchiseuserid = 0
	END

	--select CONVERT(xml, @XMLString)
	IF CONVERT(int, @user_id) < 500000
	BEGIN
  	  INSERT INTO userxfr (user_id, fran_id, sb_id, passwd, feeder_only, copy_flag, info_flag, chk_userid, rej_flag, sta_flag, lock_flag, doc_flag) 
	  values (dbo.PadString(RTrim(@user_id), '0', 6), dbo.PadString(RTrim(@Franchiseuserid), '0', 6), dbo.PadString(RTrim(@masterUser), '0', 6), @PASS, @reviewFlag, @copyFlag, @fedSysFlag, @chkFlag, @fedRejFlag, @stateFlag, @lockFlag, @docFlag)
	
	UPDATE dbcrosslinkglobal..tbluser set sb_id = RTrim(@masterUser) WHERE user_id = RTrim(@user_id)
	END
	

END



