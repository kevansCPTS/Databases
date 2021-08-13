-- =============================================
-- Author:		Jay Willis
-- Create date: 10/31/2012
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spAddUserStatusCodes] 
	-- Add the parameters for the stored procedure here
	@status_id int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE 
		@user_id int,
		@seqno int,
		@status_code varchar(7),
		@status_desc varchar(35),
		@XMLString xml,
		@XMLStringLaunch xml,
		@iSQL varchar(max)

	-- get user_id
	SELECT @user_id = user_id FROM tblXlinkUserStatusCodes WHERE status_id = @status_id

	-- get last sequence number and increment by 1
	SELECT @seqno = 0
	SELECT TOP 1 @seqno = seqno FROM tblMgmt WHERE userid = @user_id ORDER BY seqno DESC
	SELECT @seqno = @seqno + 1

	SELECT 
	@status_code = ISNULL(status_code, ''),
	@status_desc = ISNULL(status_description, '')
	FROM tblXlinkUserStatusCodes 
	WHERE status_id = @status_id

	SELECT @XMLString = '<xmldata><cmnd>UserStatusCodes</cmnd>
	<D001>' + @status_code + '</D001>
	<D002>' + @status_desc + '</D002>
	</xmldata>'

	--print convert(varchar(max),@XMLString)

    IF @seqno = 1
		BEGIN
			SELECT @XMLStringLaunch = '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>'
			INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLStringLaunch)
			SELECT @seqno = 2
		END		

	INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLString)

	UPDATE tblXlinkUserStatusCodes SET publish_date = getdate() WHERE status_id = @status_id

END


