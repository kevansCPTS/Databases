-- =============================================
-- Author:		Jay Willis
-- Create date: 10/28/2009
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spDeleteUserEFINs] 
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
		@seqno int,
		@efin varchar(6), 
		@XMLString xml,
		@XMLStringLaunch xml

	-- get user_id
	SELECT @user_id = user_id FROM tblXlinkEfinDatabase WHERE efin_id = @efin_id

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
	@user_id = tblXlinkEfinDatabase.user_id,
	@efin = efin
	FROM tblXlinkEfinDatabase
	WHERE efin_id = @efin_id 

	SELECT @XMLString = '<xmldata><cmnd>EfinDel</cmnd><EFIN>'+ 
	@efin +'</EFIN></xmldata>'

	INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLString)

END


