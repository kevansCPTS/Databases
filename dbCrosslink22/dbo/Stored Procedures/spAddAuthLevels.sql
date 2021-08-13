-- =============================================
-- Author:		Jay Willis
-- Create date: 10/29/2009
-- Description:	
-- Update: 11/22/2011 added franchise user code - Jay Willis
-- =============================================
CREATE PROCEDURE [dbo].[spAddAuthLevels] 
	-- Add the parameters for the stored procedure here
	@usersettings_id int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE
		@user_id int,
		@seqno int,
		@authorization_level int,
		@Level_name varchar(50),
		@level_id int,
		@detail varchar (200),
		@XMLString varchar(max),
		@XMLStringLaunch xml,
		@iSQL varchar(max),
		@Franchiseuserid int

	SELECT @XMLString = '<xmldata><cmnd>Level</cmnd>'

	-- get user_id
	SELECT @user_id = user_id, 
	       @authorization_level = authorization_level,
		   @Franchiseuserid = ISNULL(franchiseuser_id,0)
	FROM   dbo.tblXlinkUserSettings 
	WHERE  usersettings_id = @usersettings_id

	-- get last sequence number and increment by 1
	SELECT @seqno = 0
	SELECT TOP 1 @seqno = seqno FROM dbo.tblMgmt WHERE userid = @user_id ORDER BY seqno DESC
	SELECT @seqno = @seqno + 1

	-- declare the cursor
	DECLARE cur_rs CURSOR FOR
	SELECT level_name, 
		   detail
	FROM   tblXlinkAccessLevels left join tblXlinkAccessDetail
	ON	   tblxlinkaccessLevels.level_id = tblxlinkaccessdetail.level_id	
	WHERE  set_id = @authorization_level
		   AND ISNULL(tblXlinkAccessLevels.franchiseuser_id,0) = @Franchiseuserid
		   AND ISNULL(tblXlinkAccessDetail.franchiseuser_id,0) = @Franchiseuserid

	--open the cursor
	open cur_rs

	--fetch the first value
	FETCH NEXT FROM cur_rs INTO @level_name, @detail

	WHILE (@@FETCH_STATUS=0)
	BEGIN

	SELECT @XMLString = @XMLString + '<' + @level_name + '>' + ISNULL(@detail,'') + '</' + @level_name + '>'

	-- Fetch the next value.
	FETCH NEXT FROM cur_rs INTO @level_name, @detail
	END

	-- Close the cursor.
	CLOSE cur_rs

	-- Clean up memory
	DEALLOCATE cur_rs

	select @XMLString = @XMLString + '</xmldata>'

    IF @seqno = 1
	BEGIN
		SELECT @XMLStringLaunch = '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>'
		INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLStringLaunch)
		SELECT @seqno = 2
	END		

	INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLString)

	UPDATE tblXlinkAccessSets SET publish_date = getdate() WHERE set_id = @authorization_level

	-- Insert into tblAdmin for sync'ing messages with the backend.
--	INSERT INTO admin (delivered, req_type, param, ssn, dt, requestor) values (' ', 'M', dbo.PadString(@seqno, '0', 6), rtrim(convert(char(6), @user_id)), getdate(), 'portal')

END


