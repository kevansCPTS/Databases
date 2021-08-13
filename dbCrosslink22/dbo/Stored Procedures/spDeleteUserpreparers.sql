-- =============================================
-- Author:		Jay Willis
-- Create date: 10/28/2009
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spDeleteUserpreparers] 
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
		@XMLString xml,
		@XMLStringLaunch xml

	-- get user_id
	SELECT @user_id = user_id FROM tblXlinkPreparerDatabase WHERE preparer_id = @preparer_id

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
	@user_id = tblXlinkPreparerDatabase.user_id,
	@shortcut_id = shortcut_id
	FROM tblXlinkPreparerDatabase
	WHERE preparer_id = @preparer_id 

	SELECT @XMLString = '<xmldata><cmnd>PaidPreparerDel</cmnd><D001>'+ 
	@shortcut_id +'</D001></xmldata>'

	INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLString)

END


