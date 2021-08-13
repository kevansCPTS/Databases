-- =============================================
-- Author:		Jay Willis
-- Create date: 10/28/2009
-- Update date: 12/15/2010 Changed to Left Join to make sure that I get a record back. JW
-- Update date: 9/1/2015 set change_password back to null after publish JW
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spAddUserLogins] 
	-- Add the parameters for the stored procedure here
	@userlogin_id int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE 
		@user_id int,
		@seqno int,
		@login_id varchar(50), 
		@login_name varchar(30), 
		@level_name varchar(30), 
		@shortcut_id varchar(3),
		@password_reset varchar(1),
		@training_returns_only varchar(1),
		@show_fees_in_transmit varchar(1),
		@display_short_form varchar(1),
		@hide_work_in_progress varchar(1),
		@email varchar(50),
		@cell_phone varchar(10),
		@password varchar(16),
		@RBIN varchar(8),
		@aes_key varchar(35),
		@XMLString xml,
		@XMLStringLaunch xml,
		@paid_preparer_id varchar(7),
		@iSQL varchar(max),
		@Franchiseuserid int

	-- get user_id
	SELECT @user_id = user_id,
	@Franchiseuserid = ISNULL(franchiseuser_id, 0)
	FROM   tblXlinkUserLogins 
	WHERE userlogin_id = @userlogin_id

	-- get last sequence number and increment by 1
	SELECT @seqno = 0
	SELECT TOP 1 @seqno = seqno FROM tblMgmt WHERE userid = @user_id ORDER BY seqno DESC
	SELECT @seqno = @seqno + 1

	SELECT @user_id = tblXlinkUserLogins.user_id,
		   @login_id = login_id,
	       @login_name = login_name,
		   @level_name = isnull(level_name,''),
	       @shortcut_id = isnull(shortcut_id, ''),
	       @password_reset = ISNULL(change_password, ''),
		   @training_returns_only = ISNULL(training_returns_only, ''),
		   @show_fees_in_transmit = ISNULL(show_fees_in_transmit, ''),
	       @display_short_form = isnull(display_short_form,''),
	       @hide_work_in_progress = isnull(hide_work_in_progress,''),
	       @password = login_password,
	       @paid_preparer_id = isnull(shortcut_id,''),
		   @email = ISNULL(email,''),
		   @cell_phone = ISNULL(cell_phone, ''),
	       @RBIN = isnull(RBIN,'')
	FROM   tblXlinkUserLogins
	LEFT JOIN tblXlinkAccessLevels 
	ON     access_level = level_id
	WHERE  userlogin_id = @userlogin_id 
	       AND ISNULL(tblXlinkUserLogins.franchiseuser_id, 0) = @Franchiseuserid
	       AND ISNULL(tblXlinkAccessLevels.franchiseuser_id, 0) = @Franchiseuserid

	SELECT TOP 1 @aes_key = enc_key 
	FROM   tblXlinkUserSettings 
	WHERE  user_id = @user_id
		   AND ISNULL(franchiseuser_id, 0) = @Franchiseuserid
	ORDER BY usersettings_id DESC

	SELECT @XMLString = '<xmldata><cmnd>Login</cmnd><NAME>'+ upper(@login_id) +'</NAME>'
	+ '<UNAM>'+ @login_name +'</UNAM>'
	+ '<AUTH>'+ @level_name +'</AUTH>'
	+ '<PPID>'+ @shortcut_id +'</PPID>'
	+ '<TNGO>'+ @training_returns_only +'</TNGO>'
	+ '<PRPS>'+ @show_fees_in_transmit +'</PRPS>'
	+ '<INVL>'+ @display_short_form +'</INVL>'
	+ '<WIPX>'+ @hide_work_in_progress +'</WIPX>'
	+ '<RSET>'+ @password_reset +'</RSET>'
	+ '<PWDX>'+ @password +'</PWDX>'
	+ '<PPID>'+ @paid_preparer_id +'</PPID>'
	+ '<EMAL>'+ @email +'</EMAL>'
	+ '<CELL>'+ @cell_phone +'</CELL>'
	+ '<BAID>'+ @RBIN +'</BAID>'
	+ '<AESK>'+ ISNULL(@aes_key,'') +'</AESK></xmldata>'

    IF @seqno = 1
		BEGIN
			SELECT @XMLStringLaunch = '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>'
			INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLStringLaunch)
			SELECT @seqno = 2
		END		

	INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLString)

	UPDATE tblXlinkUserLogins SET publish_date = getdate(), change_password = NULL WHERE userlogin_id = @userlogin_id

	-- Insert into tblAdmin for sync'ing messages with the backend.
--	INSERT INTO admin (delivered, req_type, param, ssn, dt, requestor) VALUES (' ', 'M', dbo.PadString(@seqno, '0', 6), rtrim(convert(char(6), @user_id)), getdate(), 'portal')

END

