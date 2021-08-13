
-- =============================================
-- Author:		Jay Willis
-- Create date: 10/29/2009
-- Update date: 12/28/2010
-- Description:	
-- Update: 11/21/2011 added franchise user code - Jay Willis
-- Update: 1/5/2016 added 5 more custom charges fields
-- =============================================
CREATE PROCEDURE [dbo].[spAddBilling] 
	-- Add the parameters for the stored procedure here
	@usersettings_id int
,   @schedule_type char(1) = null
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE
		@user_id int,
		@seqno int,
		@account_id varchar(8),
		@billing_schedule int,
		@schedule_name varchar(50),
		@schedule_id varchar(10),
		@schedule_seqno varchar(10),
		@form_id varchar(7),
		@form_price varchar(10),
		@XMLString varchar(max),
		@XMLStringLaunch xml,
		@iSQL varchar(max),
		@DPFee varchar(4),		
		@EFFee varchar(4),		
		@OFF1 varchar(35),
		@OFF2 varchar(35),
		@OFF3 varchar(35),
		@OFF4 varchar(35),
		--@AUDT varchar(4),
		--@AUDF char(1),
		@EFOL char(1),
		@STAX varchar(6),
		@HOUR varchar(6),
		@DSCP varchar(6),
		@SELF varchar(6),
		@INVD char(1),
		@FTAX char(1),
		@DI03 varchar(15),
		@DA03 varchar(6),
		@DB03 varchar(6),
		@DI04 varchar(15),
		@DA04 varchar(6),
		@DB04 varchar(6),
		@DI05 varchar(15),
		@DA05 varchar(6),
		@DB05 varchar(6),
		@DI06 varchar(15),
		@DA06 varchar(6),
		@DB06 varchar(6),
		@DI07 varchar(15),
		@DA07 varchar(6),
		@DB07 varchar(6),
		@DI08 varchar(15),
		@DA08 varchar(6),
		@DB08 varchar(6),
		@EI03 varchar(15),
		@EA03 varchar(6),
		@EI04 varchar(15),
		@EA04 varchar(6),
		@EI05 varchar(15),
		@EA05 varchar(6),
		@EI06 varchar(15),
		@EA06 varchar(6),
		@EI07 varchar(15),
		@EA07 varchar(6),
		@EI08 varchar(15),
		@EA08 varchar(6),
		@EI09 varchar(15),
		@EA09 varchar(6),
		@EI10 varchar(15),
		@EA10 varchar(6),
		@EI11 varchar(15),
		@EA11 varchar(6),
		@EI12 varchar(15),
		@EA12 varchar(6),
		@PYBL varchar(1),
		@PYPF varchar(1),
		@BADS char(1),
		@SCHA char(1),
		@NTDU char(1),
		@INWN char(1),
		@DFLT varchar(6),
		--@ACDR varchar(1),
		@Franchiseuserid int

	SELECT @XMLString = '<xmldata><cmnd>Billing</cmnd>'

	-- get user_id and billing_schedule
	SELECT @user_id = user_id, @billing_schedule = billing_schedule,
			@DPFee = replace(floor(IsNull(DPFee,0)*100), '.00',''),
			@EFFee = replace(floor(IsNull(EFFee,0)*100), '.00',''),
			--@AUDT =  replace(floor(IsNull(protection_plus_fee,0)*100), '.00',''),
			--@AUDF = auto_add_audit_protection,
			@OFF1 = ISNULL(office_info1, ''),
			@OFF2 = ISNULL(office_info2, ''),
			@OFF3 = ISNULL(office_info3, ''),
			@OFF4 = ISNULL(office_info4, ''),
			@EFOL = ef_forms_only,
			@STAX = dbo.PadString(replace(floor(IsNull(sales_tax,0)*1000), '.00',''),0,5),
			@HOUR = replace(floor(IsNull(default_rate,0)*100), '.00',''),
			@DSCP = replace(floor(IsNull(tax_prep_discount,0)*100), '.00',''),
			@SELF = replace(floor(IsNull(self_prepared_fee,0)*100), '.00',''),
			@INVD = disable_invoicing,
			@FTAX = collect_on_billing,

			@PYBL = no_prior_year_bal,
			@PYPF = no_prior_year_prep,
			@BADS = turn_off_disbursements,

			@SCHA = dont_bill_schda,
			@NTDU = prevent_transmit_balance_due,
			@INWN = disable_invoice_warning,
			--@ACDR = auto_add_cadr_plus,
			@account_id = account_id,
            @Franchiseuserid = ISNULL(franchiseuser_id,0)

	FROM tblXlinkUserSettings 
	WHERE usersettings_id = @usersettings_id

-- if a business type selct bus billing schedule
if (@schedule_type = 'C')
	BEGIN
	SELECT @billing_schedule = bus_billing_schedule
	FROM tblXlinkUserSettings
	WHERE usersettings_id = @usersettings_id
	END
	

IF (@billing_schedule <> 499 AND @billing_schedule <> 498)
 BEGIN

	-- get last sequence number and increment by 1
	SELECT @seqno = 0
	SELECT TOP 1 @seqno = seqno FROM tblMgmt WHERE userid = @user_id ORDER BY seqno DESC
	SELECT @seqno = @seqno + 1

	-- get schedule_name and id
	SELECT @schedule_name = schedule_name, 
	       @schedule_id = schedule_id, 
	       @schedule_seqno = schedule_seqno
	FROM   tblXlinkSchedules 
	WHERE  schedule_seqno = @billing_schedule 
	       AND account_id = @account_id
	       AND ISNULL(tblXlinkSchedules.franchiseuser_id,0) = @Franchiseuserid

	-- get discounts if any added 12/28/10 JW
	SELECT @DI03 = discount_name_1, 
	       @DI04 = discount_name_2, 
	       @DI05 = discount_name_3, 
	       @DI06 = discount_name_4, 
	       @DI07 = discount_name_5, 
	       @DI08 = discount_name_6, 
	       @DA03 = replace(floor(ISNULL(discount_amount_1,0) * 100),'.00',''),
	       @DA04 = replace(floor(ISNULL(discount_amount_2,0) * 100),'.00',''),
	       @DA05 = replace(floor(ISNULL(discount_amount_3,0) * 100),'.00',''),
	       @DA06 = replace(floor(ISNULL(discount_amount_4,0) * 100),'.00',''),
	       @DA07 = replace(floor(ISNULL(discount_amount_5,0) * 100),'.00',''),
	       @DA08 = replace(floor(ISNULL(discount_amount_6,0) * 100),'.00',''),
	       @DB03 = replace(floor(ISNULL(discount_percent_1,0) * 100),'.00',''),
	       @DB04 = replace(floor(ISNULL(discount_percent_2,0) * 100),'.00',''),
	       @DB05 = replace(floor(ISNULL(discount_percent_3,0) * 100),'.00',''),
	       @DB06 = replace(floor(ISNULL(discount_percent_4,0) * 100),'.00',''),
	       @DB07 = replace(floor(ISNULL(discount_percent_5,0) * 100),'.00',''),
	       @DB08 = replace(floor(ISNULL(discount_percent_6,0) * 100),'.00',''),
	       @DFLT = replace(floor(ISNULL(override_fee,0) * 100),'.00','')
	FROM   tblXlinkDiscounts
	WHERE  schedule_id = @schedule_id 
		   AND account_id = @account_id
	       AND ISNULL(tblXlinkDiscounts.franchiseuser_id,0) = @Franchiseuserid

	-- get charges if any added 09/21/12 JW
	SELECT @EI03 = charge_name_1, 
	       @EI04 = charge_name_2, 
	       @EI05 = charge_name_3, 
	       @EI06 = charge_name_4, 
	       @EI07 = charge_name_5, 
	       @EI08 = charge_name_6, 
	       @EI09 = charge_name_7, 
	       @EI10 = charge_name_8, 
	       @EI11 = charge_name_9, 
	       @EI12 = charge_name_10, 
	       @EA03 = replace(floor(ISNULL(charge_amount_1,0) * 100),'.00',''),
	       @EA04 = replace(floor(ISNULL(charge_amount_2,0) * 100),'.00',''),
	       @EA05 = replace(floor(ISNULL(charge_amount_3,0) * 100),'.00',''),
	       @EA06 = replace(floor(ISNULL(charge_amount_4,0) * 100),'.00',''),
	       @EA07 = replace(floor(ISNULL(charge_amount_5,0) * 100),'.00',''),
	       @EA08 = replace(floor(ISNULL(charge_amount_6,0) * 100),'.00',''),
	       @EA09 = replace(floor(ISNULL(charge_amount_7,0) * 100),'.00',''),
	       @EA10 = replace(floor(ISNULL(charge_amount_8,0) * 100),'.00',''),
	       @EA11 = replace(floor(ISNULL(charge_amount_9,0) * 100),'.00',''),
	       @EA12 = replace(floor(ISNULL(charge_amount_10,0) * 100),'.00','')
	FROM   tblXlinkCustomCharges
	WHERE  schedule_id = @schedule_id 
		   AND account_id = @account_id
	       AND ISNULL(tblXlinkCustomCharges.franchiseuser_id,0) = @Franchiseuserid

	IF (@EA03 = '0') BEGIN SELECT @EA03 = '' END
	IF (@EA04 = '0') BEGIN SELECT @EA04 = '' END
	IF (@EA05 = '0') BEGIN SELECT @EA05 = '' END
	IF (@EA06 = '0') BEGIN SELECT @EA06 = '' END
	IF (@EA07 = '0') BEGIN SELECT @EA07 = '' END
	IF (@EA08 = '0') BEGIN SELECT @EA08 = '' END
	IF (@EA09 = '0') BEGIN SELECT @EA09 = '' END
	IF (@EA10 = '0') BEGIN SELECT @EA10 = '' END
	IF (@EA11 = '0') BEGIN SELECT @EA11 = '' END
	IF (@EA12 = '0') BEGIN SELECT @EA12 = '' END
	IF (@DA03 = '0') BEGIN SELECT @DA03 = '' END
	IF (@DA04 = '0') BEGIN SELECT @DA04 = '' END
	IF (@DA05 = '0') BEGIN SELECT @DA05 = '' END
	IF (@DA06 = '0') BEGIN SELECT @DA06 = '' END
	IF (@DA07 = '0') BEGIN SELECT @DA07 = '' END
	IF (@DA08 = '0') BEGIN SELECT @DA08 = '' END
	IF (@DB03 = '0') BEGIN SELECT @DB03 = '' END
	IF (@DB04 = '0') BEGIN SELECT @DB04 = '' END
	IF (@DB05 = '0') BEGIN SELECT @DB05 = '' END
	IF (@DB06 = '0') BEGIN SELECT @DB06 = '' END
	IF (@DB07 = '0') BEGIN SELECT @DB07 = '' END
	IF (@DB08 = '0') BEGIN SELECT @DB08 = '' END
	IF (@DFLT = '0') BEGIN SELECT @DFLT = '' END

	-- Prepare XML String
if (@schedule_type = 'C') 
	BEGIN SELECT @XMLString = @XMLString + '<RECN>C' + IsNull(@schedule_seqno,'') + '</RECN>' END
ELSE	
	BEGIN SELECT @XMLString = @XMLString + '<RECN>I' + IsNull(@schedule_seqno,'') + '</RECN>' END

	SELECT @XMLString = @XMLString + '<NAME>' + IsNull(@schedule_name,'') + '</NAME>'
	SELECT @XMLString = @XMLString + '<DFEE>' + @DPFEE + '</DFEE>'
	SELECT @XMLString = @XMLString + '<EFEE>' + @EFFee + '</EFEE>'
--	SELECT @XMLString = @XMLString + '<AUDT>' + @AUDT + '</AUDT>'
--	SELECT @XMLString = @XMLString + '<AUDF>' + IsNull(@AUDF,'') + '</AUDF>'
	SELECT @XMLString = @XMLString + '<OFF1>' + @OFF1 + '</OFF1>'
	SELECT @XMLString = @XMLString + '<OFF2>' + @OFF2 + '</OFF2>'
	SELECT @XMLString = @XMLString + '<OFF3>' + @OFF3 + '</OFF3>'
	SELECT @XMLString = @XMLString + '<OFF4>' + @OFF4 + '</OFF4>'
	SELECT @XMLString = @XMLString + '<EFOL>' + IsNull(@EFOL,'') + '</EFOL>'
	SELECT @XMLString = @XMLString + '<STAX>' + @STAX + '</STAX>'
	SELECT @XMLString = @XMLString + '<HOUR>' + @HOUR + '</HOUR>'
	SELECT @XMLString = @XMLString + '<DSCP>' + @DSCP + '</DSCP>'
	SELECT @XMLString = @XMLString + '<SELF>' + @SELF + '</SELF>'
	SELECT @XMLString = @XMLString + '<INVD>' + IsNull(@INVD,'') + '</INVD>'
	SELECT @XMLString = @XMLString + '<FTAX>' + IsNull(@FTAX,'') + '</FTAX>'
	SELECT @XMLString = @XMLString + '<DI03>' + IsNull(@DI03,'') + '</DI03>'
	SELECT @XMLString = @XMLString + '<DA03>' + IsNull(@DA03,'') + '</DA03>'
	SELECT @XMLString = @XMLString + '<DB03>' + IsNull(@DB03,'') + '</DB03>'
	SELECT @XMLString = @XMLString + '<DI04>' + IsNull(@DI04,'') + '</DI04>'
	SELECT @XMLString = @XMLString + '<DA04>' + IsNull(@DA04,'') + '</DA04>'
	SELECT @XMLString = @XMLString + '<DB04>' + IsNull(@DB04,'') + '</DB04>'
	SELECT @XMLString = @XMLString + '<DI05>' + IsNull(@DI05,'') + '</DI05>'
	SELECT @XMLString = @XMLString + '<DA05>' + IsNull(@DA05,'') + '</DA05>'
	SELECT @XMLString = @XMLString + '<DB05>' + IsNull(@DB05,'') + '</DB05>'
	SELECT @XMLString = @XMLString + '<DI06>' + IsNull(@DI06,'') + '</DI06>'
	SELECT @XMLString = @XMLString + '<DA06>' + IsNull(@DA06,'') + '</DA06>'
	SELECT @XMLString = @XMLString + '<DB06>' + IsNull(@DB06,'') + '</DB06>'
	SELECT @XMLString = @XMLString + '<DI07>' + IsNull(@DI07,'') + '</DI07>'
	SELECT @XMLString = @XMLString + '<DA07>' + IsNull(@DA07,'') + '</DA07>'
	SELECT @XMLString = @XMLString + '<DB07>' + IsNull(@DB07,'') + '</DB07>'
	SELECT @XMLString = @XMLString + '<DI08>' + IsNull(@DI08,'') + '</DI08>'
	SELECT @XMLString = @XMLString + '<DA08>' + IsNull(@DA08,'') + '</DA08>'
	SELECT @XMLString = @XMLString + '<DB08>' + IsNull(@DB08,'') + '</DB08>'
	SELECT @XMLString = @XMLString + '<EI03>' + IsNull(@EI03,'') + '</EI03>'
	SELECT @XMLString = @XMLString + '<EA03>' + IsNull(@EA03,'') + '</EA03>'
	SELECT @XMLString = @XMLString + '<EI04>' + IsNull(@EI04,'') + '</EI04>'
	SELECT @XMLString = @XMLString + '<EA04>' + IsNull(@EA04,'') + '</EA04>'
	SELECT @XMLString = @XMLString + '<EI05>' + IsNull(@EI05,'') + '</EI05>'
	SELECT @XMLString = @XMLString + '<EA05>' + IsNull(@EA05,'') + '</EA05>'
	SELECT @XMLString = @XMLString + '<EI06>' + IsNull(@EI06,'') + '</EI06>'
	SELECT @XMLString = @XMLString + '<EA06>' + IsNull(@EA06,'') + '</EA06>'
	SELECT @XMLString = @XMLString + '<EI07>' + IsNull(@EI07,'') + '</EI07>'
	SELECT @XMLString = @XMLString + '<EA07>' + IsNull(@EA07,'') + '</EA07>'
	SELECT @XMLString = @XMLString + '<EI08>' + IsNull(@EI08,'') + '</EI08>'
	SELECT @XMLString = @XMLString + '<EA08>' + IsNull(@EA08,'') + '</EA08>'
	SELECT @XMLString = @XMLString + '<EI09>' + IsNull(@EI09,'') + '</EI09>'
	SELECT @XMLString = @XMLString + '<EA09>' + IsNull(@EA09,'') + '</EA09>'
	SELECT @XMLString = @XMLString + '<EI10>' + IsNull(@EI10,'') + '</EI10>'
	SELECT @XMLString = @XMLString + '<EA10>' + IsNull(@EA10,'') + '</EA10>'
	SELECT @XMLString = @XMLString + '<EI11>' + IsNull(@EI11,'') + '</EI11>'
	SELECT @XMLString = @XMLString + '<EA11>' + IsNull(@EA11,'') + '</EA11>'
	SELECT @XMLString = @XMLString + '<EI12>' + IsNull(@EI12,'') + '</EI12>'
	SELECT @XMLString = @XMLString + '<EA12>' + IsNull(@EA12,'') + '</EA12>'
	SELECT @XMLString = @XMLString + '<PYBL>' + IsNull(@PYBL,'') + '</PYBL>'
	SELECT @XMLString = @XMLString + '<PYPF>' + IsNull(@PYPF,'') + '</PYPF>'
	SELECT @XMLString = @XMLString + '<BADS>' + IsNull(@BADS,'') + '</BADS>'
	SELECT @XMLString = @XMLString + '<SCHA>' + IsNull(@SCHA,'') + '</SCHA>'
	SELECT @XMLString = @XMLString + '<NTDU>' + IsNull(@NTDU,'') + '</NTDU>'
	SELECT @XMLString = @XMLString + '<INWN>' + IsNull(@INWN,'') + '</INWN>'
	if (@account_id = 'CTTS00' or @account_id = 'CTTS02')  BEGIN
	SELECT @XMLString = @XMLString + '<DFLT>' + IsNull(@DFLT,'') + '</DFLT>'
	END
--	SELECT @XMLString = @XMLString + '<ACDR>' + IsNull(@ACDR,'') + '</ACDR>'

	--declare the cursor
	DECLARE cur_rs CURSOR FOR
	SELECT form_id, replace(floor(ISNULL(form_price,0) * 100),'.00','')
	FROM tblXlinkBilling, tblXlinkSchedules 
	WHERE schedule_seqno = @Billing_schedule
	AND tblXlinkBilling.schedule_id = tblXlinkSchedules.schedule_id
	AND tblXlinkBilling.account_id = @account_id
	AND tblxlinkbilling.schedule_id = @schedule_id
    AND ISNULL(tblXlinkSchedules.franchiseuser_id,0) = @Franchiseuserid
    AND ISNULL(tblXlinkBilling.franchiseuser_id,0) = @Franchiseuserid

	--open the cursor
	open cur_rs

	--fetch the first value
	FETCH NEXT FROM cur_rs INTO @form_id, @form_price

	WHILE (@@FETCH_STATUS=0)
	BEGIN

	--make sure the quantity values are not multiplied by 100
	IF RIGHT(@form_id,1) in ('2','5','8') BEGIN SELECT @form_price = @form_price/100 END

    --if form price is 0 then clear xml tag
	IF (convert(int, @form_price) = 0 and LEFT(@form_id,4) <> 'CLNT') BEGIN SELECT @form_price = '' END

	SELECT @XMLString = @XMLString + '<' + LEFT(@form_id,5) + RIGHT(@form_id,1) + '>' + @form_price + '</' + LEFT(@form_id,5) + RIGHT(@form_id,1) + '>'

	-- Fetch the next value.
	FETCH NEXT FROM cur_rs INTO @form_id, @form_price
	END

	-- Close the cursor.
	CLOSE cur_rs

	-- Clean up memory
	DEALLOCATE cur_rs

	-- THESE NEED TO BE MOVED TO GLOBAL
	IF (@account_id = 'MAHJOS') -- Auto Adds for Health and Identity Protection
	BEGIN
		SELECT @XMLString = @XMLString 
		+ '<AHCF>X</AHCF>'
		+ '<AHCN>X</AHCN>'
		+ '<AUIP>X</AUIP>'
	END
							
	SELECT @XMLString = @XMLString + '</xmldata>'

    IF @seqno = 1
		BEGIN
			SELECT @XMLStringLaunch = '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>'
			INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLStringLaunch)
			SELECT @seqno = 2
		END		

	INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLString)

	UPDATE tblXlinkSchedules SET publish_date = getdate() WHERE @schedule_id = schedule_id 	AND account_id = @account_id

 END	
	-- Insert into tblAdmin for sync'ing messages with the backend.

--	INSERT INTO admin (delivered, req_type, param, ssn, dt, requestor) values (' ','M',dbo.PadString(@seqno, '0', 6),rtrim(convert(char(6), @user_id)), getdate(), 'portal')
	
END



