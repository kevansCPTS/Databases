-- =============================================
-- Author:		Jay Willis
-- Create date: 10/29/2009
-- Update date: 12/28/2010
-- Description:	
-- Update: 11/21/2011 added franchise user code - Jay Willis
-- =============================================
CREATE PROCEDURE [dbo].[spAddRestrictedForms] 
	-- Add the parameters for the stored procedure here
	@useridtoedit_id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE
		@user_id int,
		@seqno int,
		@account_id varchar(8),
		@form_id varchar(7),
		@restrict_add bit,
		@restrict_edit bit,
		@XMLString varchar(max),
		@XMLStringLaunch xml,
		@Franchiseuserid int

	SELECT @XMLString = '<xmldata><cmnd>RestrictedForms</cmnd>'

	-- get user_id
	SELECT @user_id = user_id,
			@account_id = account_id,
            @Franchiseuserid = ISNULL(franchiseuser_id,0)
	FROM tblXlinkUserSettings 
	WHERE user_id = @useridtoedit_id

	-- get last sequence number and increment by 1
	SELECT @seqno = 0
	SELECT TOP 1 @seqno = seqno FROM tblMgmt WHERE userid = @user_id ORDER BY seqno DESC
	SELECT @seqno = @seqno + 1
	
	--declare the cursor
	DECLARE cur_rs CURSOR FOR
	SELECT form_id, ISNULL(restrict_add,0), ISNULL(restrict_edit, 0)
	FROM tblXlinkRestrictedForms
	WHERE user_id = @user_id
    AND ISNULL(tblXlinkRestrictedForms.franchiseuser_id,0) = @Franchiseuserid

	--open the cursor
	open cur_rs

	--fetch the first value
	FETCH NEXT FROM cur_rs INTO @form_id, @restrict_add, @restrict_edit

	WHILE (@@FETCH_STATUS=0)
	BEGIN

	--make sure the quantity values are not multiplied by 100
	IF @restrict_add = 1 or @restrict_edit = 1 
	BEGIN
		SELECT @XMLString = @XMLString + '<' + LEFT(@form_id,4) + '>' + CONVERT(Char(1), @restrict_add) + CONVERT(Char(1), @restrict_edit) + '</' + LEFT(@form_id,4) + '>'
	END
	
	-- Fetch the next value.
	FETCH NEXT FROM cur_rs INTO @form_id, @restrict_add, @restrict_edit
	END

	-- Close the cursor.
	CLOSE cur_rs

	-- Clean up memory
	DEALLOCATE cur_rs

	SELECT @XMLString = @XMLString + '</xmldata>'
	
	--print @XMLString

    IF @seqno = 1
		BEGIN
			SELECT @XMLStringLaunch = '<xmldata><cmnd>Launch</cmnd><NAME /><PHONE /><LOCATION /><FAX /><EMAIL /><SITE /><XMIT /><XFRSETUP /><XFRBILL /><XFRDB/><XFRLOGIN /><XFRAPPT /><ADMP /><AESK /></xmldata>'
			INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLStringLaunch)
			SELECT @seqno = 2
		END		

	INSERT INTO tblMgmt (delivered, userid, seqno, xmldata) VALUES (' ',@user_id,@seqno,@XMLString)

	UPDATE tblXlinkRestrictedForms SET publish_date = getdate() WHERE user_id = @user_id
	AND ISNULL(tblXlinkRestrictedForms.franchiseuser_id,0) = @Franchiseuserid
		
END


