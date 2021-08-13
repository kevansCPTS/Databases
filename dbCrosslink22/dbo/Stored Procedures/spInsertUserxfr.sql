
-- =============================================
-- Author:		Charles Krebs
-- Create date: 2/7/2011
-- Description:	Publish the indicated User Record
-- Update: 01/08/2013 added docFlag to userxfr insert
-- =============================================
CREATE PROCEDURE [dbo].[spInsertUserxfr] 
	-- Add the parameters for the stored procedure here
@user_ID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	DECLARE 
		@PASS char(8), @user_ID_string char(6),
		@copyFlag char(1),		@reviewFlag char(1),	@lockFlag char(1),	@fedSysFlag char(1),
		@fedRejFlag char(1),	@stateFlag char(1),		@chkFlag char(1),	@masterUser char(6),
		@docFlag char(1),
		@XMIT char(1),	@BILL varchar(10), @Chk_UserID varchar(5)

	SELECT	@PASS = IsNull(transmit_password, ''), 
			@copyFlag = IsNull(main_office_copy, ''),	
			@docFlag = IsNull(main_office_copy_docs, ''),	
			@reviewFlag = IsNull(main_office_review, ''),
			@fedSysFlag = CASE IsNull(fed_system_messages, '')
				WHEN 'O' THEN 0 
				WHEN 'M' THEN 1
				WHEN 'B' THEN 2
			END,
			@fedRejFlag = CASE IsNull(fed_reject_messages, '')
				WHEN 'O' THEN 0 
				WHEN 'M' THEN 1
				WHEN 'B' THEN 2
			END,
			@stateFlag = CASE IsNull(state_messages, '')
				WHEN 'O' THEN 0 
				WHEN 'M' THEN 1
				WHEN 'B' THEN 2
			END,
			@chkFlag = CASE IsNull(check_print, '')
				WHEN 'O' THEN 0 
				WHEN 'M' THEN 1
				WHEN 'B' THEN 2
			END,
			@masterUser = master_id,
			@XMIT = transmit_type,
			@BILL = billing_schedule,
			@lockFlag = lock_flag,
			@Chk_UserID = chk_userid

	FROM tblXlinkUserSettings WHERE user_ID = @user_ID

-- if transmit type is not a feeder '0' then uncheck the reviewFlag
	If @XMIT <> '0' BEGIN Select @reviewFlag = '' END

	If RTrim(@user_id) = RTrim(@masterUser)
	BEGIN
		SELECT @masterUser = '0',
-- if this office is the master then don't require review
		@reviewFlag = ''
	END

	INSERT INTO userxfr (user_id, sb_id, passwd, feeder_only, copy_flag, info_flag, chk_userid, rej_flag, sta_flag, lock_flag, doc_flag) 
	values (dbo.PadString(RTrim(Convert(varchar(6), @user_id)), '0', 6), dbo.PadString(RTrim(@masterUser), '0', 6), @PASS, @reviewFlag, @copyFlag, @fedSysFlag, @Chk_UserID, @fedRejFlag, @stateFlag, @lockFlag, @docFlag)
END


--GRANT EXECUTE ON spInsertUserXFR to taxman_csr







