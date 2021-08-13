
-- =============================================
-- Author:		Jay Willis
-- Create date: ??
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[spPublishTags] 
	-- Add the parameters for the stored procedure here
	--@usersettings_id int
	@user_id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE 
		@currentSeason int = dbo.getXlinkSeason(),
		--@user_id varchar(6),
		@seqno int,				
		@XMLString varchar(max),
		@XMLStringLaunch xml,
		@XMLCSTString varchar(200),
		@OutString varchar(max),
		@account varchar(8),
		@OFID varchar(8)

	-- get account code and eroid
	SELECT @account = account, @OFID = eroid
	FROM dbCrosslinkGlobal..tblUser  WHERE user_id = @user_id

	-- get last sequence number and increment by 1
	SELECT @seqno = 0
	SELECT TOP 1 @seqno = seqno FROM tblMgmt WHERE userid = @user_id ORDER BY seqno DESC
	SELECT @seqno = @seqno + 1

	EXEC dbCrosslinkGlobal..up_getCustomTags @account, @user_id, @currentSeason, @XMLCSTString OUTPUT
	--print @XMLCSTString
	EXEC up_getProductTags @user_id, @OutString OUTPUT
	--print @OutString

SELECT @XMLString = '<xmldata><cmnd>Global</cmnd>' + @XMLCSTString + @OutString + '<OFID>' + ISNULL(@OFID,'') + '</OFID>' + '</xmldata>'

--select CONVERT(varchar(max), @XMLString)

    IF @seqno = 1
		BEGIN
			SELECT @XMLStringLaunch = '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>'
			INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ', @user_id, @seqno, @XMLStringLaunch)
			SELECT @seqno = 2
		END		

	INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ', @user_id, @seqno, @XMLString)

END



