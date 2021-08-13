-- =============================================
-- Author:		Jay Willis
-- Create date: 10/28/2009
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spAddUserPreparers] 
	-- Add the parameters for the stored procedure here
	@preparer_id int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE 
		@user_id int,
		@seqno int,
		@shortcut_id varchar(7),
		@preparer_name varchar(35),
		@self_employed char(1),
		@firm_name varchar(35),
		@ein char(9),
		@address varchar(35),
		@city varchar(22),
		@state char(2),
		@zip varchar(12),
		@office_phone char(10),
		@efin char(6),
		@state_code_1 char(2),
		@state_id_1	varchar(14),
		@state_code_2 char(2),
		@state_id_2 varchar(14),
		@ptin char(9),
		@ssn char(9),
		@third_party_pin varchar(5),
		@email varchar(55),
		@default_pin varchar(5),
		@XMLString xml,
		@XMLStringLaunch xml,
		@preparer_type varchar(5),
		@caf char(9),
		@cell_phone char(10),
		@cell_phone_carrier varchar(35),
		@iSQL varchar(max)

	-- get user_id
	SELECT @user_id = user_id FROM tblXlinkPreparerDatabase WHERE preparer_id = @preparer_id

	-- get last sequence number and increment by 1
	SELECT @seqno = 0
	SELECT TOP 1 @seqno = seqno FROM tblMgmt WHERE userid = @user_id ORDER BY seqno DESC
	SELECT @seqno = @seqno + 1

	SELECT 
	@user_id = ISNULL(tblXlinkPreparerdatabase.user_id, ''),
	@shortcut_id = ISNULL(shortcut_id, ''),
	@preparer_name = ISNULL(preparer_name, ''),
	@self_employed = ISNULL(self_employed, ''),
	@firm_name = ISNULL(firm_name, ''),
	@ein = ISNULL(ein, ''),
	@address = ISNULL(address, ''),
	@city = ISNULL(city, ''),
	@state = ISNULL(state, ''),
	@zip = ISNULL(zip, ''),
	@office_phone = ISNULL(office_phone, ''),
	@efin = ISNULL(efin, ''),
	@state_code_1 = ISNULL(state_code_1, ''),
	@state_id_1 = ISNULL(state_id_1, ''),
	@state_code_2 = ISNULL(state_code_2, ''),
	@state_id_2 = ISNULL(state_id_2, ''),
	@ptin = ISNULL(ptin, ''),
	@ssn = ISNULL(ssn, ''),
	@third_party_pin = ISNULL(third_party_pin, ''),
	@email = ISNULL(email, ''),
	@default_pin = ISNULL(default_pin, ''),
	@preparer_type = ISNULL(preparer_type, ''),
	@caf = ISNULL(caf, ''),
	@cell_phone = ISNULL(cell_phone, ''),
	@cell_phone_carrier = ISNULL(cell_phone_carrier, '')
	FROM tblXlinkPreparerDatabase 
	WHERE preparer_id = @preparer_id 

	SELECT @XMLString = '<xmldata><cmnd>PaidPreparer</cmnd>
	<D001>' + @shortcut_id + '</D001>
	<D002>' + @preparer_name + '</D002>
	<D003>' + @self_employed + '</D003>
	<D004>' + @firm_name + '</D004>
	<D005>' + @ein + '</D005>
	<D006>' + @address + '</D006>
	<D007>' + @city + '</D007>
	<D008>' + @state + '</D008>
	<D009>' + @zip + '</D009>
	<D010>' + @office_phone + '</D010>
	<D011>' + @state_code_1 + '</D011>
	<D012>' + @state_id_1 + '</D012>
	<D013>' + @efin + '</D013>
	<D014>' + @state_code_2 + '</D014>
	<D015>' + @state_id_2 + '</D015>
	<D016>' + @ptin + '</D016>
	<D017>' + @ssn + '</D017>
	<D018>' + @third_party_pin + '</D018>
	<D019>' + @email + '</D019>
	<D020>' + @preparer_type + '</D020>
	<D021>' + @cell_phone + '</D021>
	<D023>' + @cell_phone_carrier + '</D023>
	<D024>' + @caf + '</D024>
	<D025>' + @default_pin + '</D025>
	</xmldata>'

    IF @seqno = 1
		BEGIN
			SELECT @XMLStringLaunch = '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>'
			INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLStringLaunch)
			SELECT @seqno = 2
		END		

--	print convert(varchar(max),@XMLString)

	INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLString)

	UPDATE tblXlinkPreparerDatabase SET publish_date = getdate() WHERE preparer_id = @preparer_id

	-- Insert into tblAdmin for sync'ing messages with the backend.
--	INSERT INTO admin (delivered, req_type, param, ssn, dt, requestor) VALUES (' ', 'M', dbo.PadString(@seqno, '0', 6), rtrim(convert(char(6), @user_id)), getdate(), 'portal')

END


