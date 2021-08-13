-- ===============================================================================
-- Author:		Jay Willis
-- Create date: 10/28/2009
-- Change Log:
--		10/28/2009		Created by Jay Willis
--		11/26/2010		Altered by Chuck Robertson
--				Removed the commented out code that was no longer needed, due 
--				to changes in the architecture.  Additionally, took out the floor 
--				and replace statements wrapping the transmitter fee and service 
--				bureau fee, as the architecture within the desktop application has 
--				changed as well.
--		12/7/2010		Updated by Jay Willis
--				Removed bank and bank fees 
--		1/7/2011		Updated by Jay Willis
--				Added back bank and bank fees 
--		1/16/2011		Updated by Jay Willis
--				Removed Bank and bank fees and added 'E' admin message
--		11/30/2011		Updated by Jay Willis
--				Removed SB fields
--		09/21/2016		Updated by Jay Willis
--				Removed Special Bank
-- ===============================================================================
CREATE PROCEDURE [dbo].[spAddUserEFINs] 
	-- Add the parameters for the stored procedure here
	@efin_id int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE 
		@user_id int,
		@padded_user_id varchar(6),
		@seqno int,
--		@bank char(1), -- selected bank from view
		@efin char(6),
		@company_name varchar(35),
		@self_employed char(1),
		@ssn char(9),
		@ein char(9),
		@address varchar(35),
		@city varchar(22),
		@state char(2),
		@zip varchar(12),
		@office_phone char(10),
		@first_dcn char(5),
		@state_code_1 char(2),
		@state_id_1	varchar(14),
		@state_code_2 char(2),
		@state_id_2 varchar(14),
		@sbin char(6),
---		@special_bank_app_loc char(2),
		@default_pin char(5),
		@transmitter_fee varchar(5),
--		@sb_fee varchar(5), -- from view
--		@sb_name varchar(15), -- from view
--		@sb_fee_all char(1), -- from view
		@cell_phone char(10),
		@cell_phone_carrier varchar(35),
		@XMLString xml,
		@XMLStringLaunch xml,
		@iSQL varchar(max)

	-- get user_id
	SELECT @user_id = user_id FROM tblXlinkEfinDatabase WHERE efin_id = @efin_id

	-- get last sequence number and increment by 1
	SELECT @seqno = 0
	SELECT TOP 1 @seqno = seqno FROM tblMgmt WHERE userid = @user_id ORDER BY seqno DESC
	SELECT @seqno = @seqno + 1

--	SELECT @BANK = (CASE ISNULL(SelectedBank, '')
--	WHEN 'R' THEN 1
--	WHEN 'S' THEN 2
--	WHEN 'A' THEN 3
--	WHEN 'I' THEN 4
--	ELSE 0
--	END),
--	@sb_fee = ISNULL(SBPrepFee,0),
--	@sb_name = ISNULL(SBName, ''),
--	@sb_fee_all = ISNULL(SBFeeAll, '')
	
--	FROM vwBankApplication WHERE EfinID = @efin_id 

	SELECT 
	@user_id = tblXlinkefindatabase.user_id,
	@efin = ISNULL(efin, ''),
    @company_name = ISNULL(company_name, ''),
	@self_employed = ISNULL(self_employed, ''),
	@ssn = ISNULL(ssn, ''),
	@ein = ISNULL(ein, ''),
	@address = ISNULL(address, ''),
	@city = ISNULL(city, ''),
	@state = ISNULL(state, ''),
	@zip = ISNULL(zip, ''),
	@office_phone = ISNULL(office_phone, ''),
	@first_dcn = ISNULL(first_dcn, ''),
	@state_code_1 = ISNULL(state_code_1, ''),
	@state_id_1 = ISNULL(state_id_1, ''),
	@state_code_2 = ISNULL(state_code_2, ''),
	@state_id_2 = ISNULL(state_id_2, ''),
	@sbin = ISNULL(sbin, ''),
---	@special_bank_app_loc = ISNULL(special_bank_app_loc, ''),
	@default_pin = ISNULL(default_pin, ''),
	@transmitter_fee = IsNull(transmitter_fee,0),
	@cell_phone = ISNULL(cell_phone, ''),
	@cell_phone_carrier = ISNULL(cell_phone_carrier, '')

	FROM tblXlinkEFINDatabase 
	WHERE efin_id = @efin_id 

	SELECT @XMLString = '<xmldata><cmnd>Efin</cmnd>' +
	'<D001>' + @efin + '</D001>' +
	'<D002>' + @company_name + '</D002>' +
	'<D003>' + @self_employed + '</D003>' +
	'<D004>' + @ssn + '</D004>' +
	'<D005>' + @ein + '</D005>' +
	'<D006>' + @address + '</D006>' +
	'<D007>' + @city + '</D007>' +
	'<D008>' + @state + '</D008>' +
	'<D009>' + @zip + '</D009>' +
	'<D010>' + @office_phone + '</D010>' +
	--'<D011>' + @first_dcn + '</D011>' +
	'<D012>' + @state_code_1 + '</D012>' +
	'<D013>' + @state_id_1 + '</D013>' +
	'<D014>' + @state_code_2 + '</D014>' +
	'<D015>' + @state_id_2 + '</D015>' +
	'<D016>' + @sbin + '</D016>' +
--	'<D018>' + @special_bank_app_loc + '</D018>' +
	'<D019>' + @default_pin + '</D019>' +
	'<D021>' + @cell_phone + '</D021>' +
	'<D023>' + @cell_phone_carrier + '</D023>' +
--	'<SBNM>' + @sb_name + '</SBNM>' +
--	'<SBNB>' + @sb_fee_all + '</SBNB>' +
	'</xmldata>'

	Select @padded_user_id = dbo.PadString(@user_id,'0',6)

    IF @seqno = 1
		BEGIN
			SELECT @XMLStringLaunch = '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>'
			INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLStringLaunch)
			SELECT @seqno = 2
		END		

	INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLString)
	UPDATE tblXlinkEfinDatabase SET publish_date = getdate() WHERE efin_id = @efin_id
    EXEC spInsertAdminMessage2 @efin , 'E', @padded_user_id, 'web-portal'

END


