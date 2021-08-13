-- =============================================
-- Author:		Jay Willis
-- Create date: 10/28/2009
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spToggleUserLogin] 
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
		@login_id varchar(8), 
		@toggle char(1),
		@XMLStringLaunch xml,
		@XMLString xml

	-- get user_id
	SELECT @user_id = user_id FROM tblXlinkUserLogins WHERE userlogin_id = @userlogin_id

	-- get last sequence number and increment by 1
	SELECT @seqno = 0
	SELECT TOP 1 @seqno = seqno FROM tblMgmt WHERE userid = @user_id ORDER BY seqno DESC
	SELECT @seqno = @seqno + 1

    IF @seqno = 1
		BEGIN
			SELECT @XMLStringLaunch = '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>'
			INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLStringLaunch)
			SELECT @seqno = 2
		END		

	SELECT 
	@user_id = tblXlinkUserLogins.user_id,
	@login_id = login_id,
	@toggle = CONVERT(char(1), disabled)
	FROM tblXlinkUserLogins
	WHERE userlogin_id = @userlogin_id 

	SELECT @XMLString = '<xmldata><cmnd>LoginModify</cmnd><NAME>' + upper(@login_id) +'</NAME><KILL>' + @toggle + '</KILL></xmldata>'

	IF @login_id <> 'ADMIN'
	BEGIN
		INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLString)
	END
END


