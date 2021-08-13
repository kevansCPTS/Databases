-- =============================================
-- Author:		Jay Willis
-- Create date: 10/30/2009
-- Update date: 12/1/2010
-- Description:	
-- Update: 11/22/2011 added TextLink Plus - Jay Willis
-- =============================================
CREATE PROCEDURE [dbo].[spAuthCodeMaintenance] 
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
		@season int,
		@offsitebackup int,
		@textlinkplus int,
--		@USTP varchar(4),
--		@STPR varchar(4),
--		@MPP1 varchar(4),
		@BACK varchar(4),
		@PACT varchar(4),
		@XMLString xml,
		@iSQL varchar(max),
		@Franchiseuserid int

	-- get season
	SELECT @season = dbo.getXlinkSeason()
	--SELECT @season = 2012

	-- get user_id
	SELECT	@user_id = user_id,
--			@MPP1 = convert(char(4), isnull(protection_plus, '')),
            @Franchiseuserid = ISNULL(franchiseuser_id,0)
	FROM tblXlinkUserSettings WHERE usersettings_id = @usersettings_id

	-- check for Secure Offsite Storage
	SELECT @offsitebackup = count(userid) from dbcrosslinkglobal..tblProductLicense
	WHERE productcode = 'SOS' and season = @season and userid = @user_id

	-- check for TextLink Plus
	SELECT @textlinkplus = count(userid) from dbcrosslinkglobal..tblProductLicense
	WHERE productcode = 'SMSP' and season = @season and userid = @user_id

	-- get last sequence number and increment by 1
	SELECT @seqno = 0
	SELECT TOP 1 @seqno = seqno FROM tblMgmt WHERE userid = @user_id ORDER BY seqno DESC
	SELECT @seqno = @seqno + 1

--	SELECT @USTP = dbo.spCalcAuthCodes ('USTP',@user_id)
--	SELECT @STPR = dbo.spCalcAuthCodes ('STPR',@user_id)

	IF @offsitebackup = 1 
		BEGIN 
			SELECT @BACK = 'X'
		END
	ELSE
		BEGIN
			SELECT @BACK = ''
		END

	IF @textlinkplus = 1 
		BEGIN 
			SELECT @PACT = 'X'
		END
	ELSE
		BEGIN
			SELECT @PACT = ''
		END

	SELECT @XMLString = '<xmldata><cmnd>AuthCode</cmnd>'
--	+ '<PAC1>' + @USTP + '</PAC1>'
--	+ '<PAC6>' + @STPR + '</PAC6>'
--	+ '<PAC8>' + @MPP1 + '</PAC8>'
	+ '<PAC9>' + @BACK + '</PAC9>'
	+ '<PACT>' + @PACT + '</PACT>'
	+ '</xmldata>'

	INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLString)

	-- Insert into tblAdmin for sync'ing messages with the backend.
--	INSERT INTO admin (delivered, req_type, param, ssn, dt, requestor) values (' ', 'M', dbo.PadString(@seqno, '0', 6), rtrim(convert(char(6), @user_id)), getdate(), 'portal')
	

END


