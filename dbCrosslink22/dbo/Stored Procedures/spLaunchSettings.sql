-- =============================================
-- Author:        Jay Willis
-- Create date: 
-- Description:   
-- Update: 11/19/2011 - Jay Willis
-- Update: 10/24/2017 - Add AdminCell and AdminEmail
-- =============================================
CREATE PROCEDURE [dbo].[spLaunchSettings] 
      -- Add the parameters for the stored procedure here
      @usersettings_id int

AS
BEGIN
      -- SET NOCOUNT ON added to prevent extra result sets from
      -- interfering with SELECT statements.
      SET NOCOUNT ON;

    -- Insert statements for procedure here
      DECLARE
            @user_id int,
            @seqno int,
            @XMLString varchar(max),
            @NAME varchar(35),
            @PHONE varchar(12),
            @LOCATION varchar(40),
            @FAX varchar(12),
            @EMAIL varchar(50),
            @BANKTEST char(1),
            @XMIT char(1),
            @SITE varchar(35),
            @XFRSETUP char(1),
            @XFRBILL char(1),
            @XFRDB char(1),
            @XFRLOGIN char(1),
            @XFRAPPT char(1),
            @ADMP varchar(35),
            @AESK varchar(35),
			@ADMINCELL varchar(10),
			@ADMINEMAIL varchar(50),
			
			@masterUser char(6),
			@Franchiseuserid int,
			@Franchiseowner int,
			@PASS char(8),
			@reviewFlag char(1),	
			@copyFlag char(1),		
			@fedSysFlag char(1),
			@chkFlag char(1),
			@fedRejFlag char(1),	
			@stateFlag char(1),		
			@lockFlag char(1),	
			@docFlag char(1)

      SELECT @user_id = user_id,
			@NAME = name, 
			@PHONE = phone, 
			@LOCATION = location, 
			@FAX = fax, 
			@EMAIL = email, 
			@XMIT = transmit_type, 
			@SITE = site_id, 
			@XFRSETUP = prior_setup, 
			@XFRBILL = prior_billing,
			@XFRDB = prior_data, 
			@XFRLOGIN = prior_logins, 
			@XFRAPPT = prior_appointments,
			@ADMP = admin_password, 
			@AESK = enc_key,
			@ADMINCELL = password_recovery_phone,
			@ADMINEMAIL = password_recovery_email,
			
			@masterUser = master_id,
			@Franchiseuserid = ISNULL(franchiseuser_id, 0),
			--@PASS = IsNull(transmit_password, ''), get directly from tbluser
			@copyFlag = IsNull(main_office_copy, ''),	
			@fedSysFlag = CASE IsNull(fed_system_messages, '')
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
			@lockFlag = lock_flag,
			@docFlag = IsNull(main_office_copy_docs, '')

      FROM   tblXlinkUserSettings 
      WHERE  usersettings_id = @usersettings_id
  	
      -- get last sequence number and increment by 1
      SELECT @seqno = 0
      SELECT TOP 1 @seqno = seqno FROM tblMgmt WHERE userid = @user_id ORDER BY seqno DESC
      SELECT @seqno = @seqno + 1

      SELECT @XMLString = '<xmldata><cmnd>Launch</cmnd>'
      + '<NAME>' + ISNULL(@NAME,'') + '</NAME>'
      + '<PHONE>' + ISNULL(@PHONE,'') + '</PHONE>'
      + '<LOCATION>' + ISNULL(@LOCATION,'') + '</LOCATION>'
      + '<FAX>' + ISNULL(@FAX,'') + '</FAX>'
      + '<EMAIL>' + ISNULL(@EMAIL,'') + '</EMAIL>'
      + '<SITE>' + ISNULL(@SITE,'') + '</SITE>'
      + '<XMIT>' + ISNULL(@XMIT,'Y') + '</XMIT>'
      + '<XFRSETUP>' + ISNULL(@XFRSETUP,'') + '</XFRSETUP>'
      + '<XFRBILL>' + ISNULL(@XFRBILL,'') + '</XFRBILL>'
      + '<XFRDB>' + ISNULL(@XFRDB,'') + '</XFRDB>'
      + '<XFRLOGIN>' + ISNULL(@XFRLOGIN,'') + '</XFRLOGIN>'
      + '<XFRAPPT>' + ISNULL(@XFRAPPT,'') + '</XFRAPPT>'
      + '<ADMP>' + ISNULL(@ADMP,'') + '</ADMP>'
      + '<AESK>' + ISNULL(@AESK,'') + '</AESK>'
      + '<ADMINCELL>' + ISNULL(@ADMINCELL,'') + '</ADMINCELL>'
      + '<ADMINEMAIL>' + ISNULL(@ADMINEMAIL,'') + '</ADMINEMAIL>'
      + '</xmldata>'

      IF (@seqno = 1)
            INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLString)
      ELSE
            UPDATE tblMgmt SET xmldata = @XMLString, delivered = ' ' where userid = @user_id and seqno = 1

-- userxfr entries
-- if transmit type is not a feeder '0' then uncheck the reviewFlag
	If @XMIT <> '0' 
	BEGIN Select @reviewFlag = '' END
	ELSE
	BEGIN Select @reviewFlag = 'X' END

-- if Franchise Owner set flag
	SELECT @Franchiseowner = count(*) FROM FranchiseOwner WHERE UserID = @user_id

	--get transmit password
	Select @PASS = ISNULL(passwd, '') from dbCrosslinkGlobal..tbluser where user_id = @user_id

	-- if this office is the master then don't require review
	If RTrim(@user_id) = RTrim(@masterUser) OR @Franchiseowner = 1
	BEGIN Select @reviewFlag = '' END

	If RTrim(@user_id) = RTrim(@masterUser)
	BEGIN
		SET @masterUser = '0'
	END

	If RTrim(@user_id) = RTrim(@Franchiseuserid)
	BEGIN
		SET @Franchiseuserid = 0
	END

	IF CONVERT(int, @user_id) < 500000
	BEGIN
  	  INSERT INTO userxfr (user_id, fran_id, sb_id, passwd, feeder_only, copy_flag, info_flag, chk_userid, rej_flag, sta_flag, lock_flag, doc_flag) 
	  values (dbo.PadString(RTrim(@user_id), '0', 6), dbo.PadString(RTrim(@Franchiseuserid), '0', 6), dbo.PadString(RTrim(@masterUser), '0', 6), 
	  @PASS, @reviewFlag, @copyFlag, @fedSysFlag, @chkFlag, @fedRejFlag, @stateFlag, @lockFlag, @docFlag)

	UPDATE dbcrosslinkglobal..tbluser set sb_id = RTrim(@masterUser) WHERE user_id = RTrim(@user_id)
	END
	

END


