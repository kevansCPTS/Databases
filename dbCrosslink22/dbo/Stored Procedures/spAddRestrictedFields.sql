


-- =============================================
-- Author:		Jay Willis
-- Create date: 10/29/2009
-- Update date: 12/28/2010
-- Description:	
-- Update: 11/21/2011 added franchise user code - Jay Willis
-- Update: 1/15/2015 check for first char as digit - Jay Willis
-- =============================================
CREATE PROCEDURE [dbo].[spAddRestrictedFields] 
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
		@restricted_field varchar(15),
		@XMLString varchar(max),
		@XMLStringLaunch xml,
		@Franchiseuserid int

	SELECT @XMLString = '<xmldata><cmnd>RestrictedFields</cmnd>'

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
	SELECT restricted_field
	FROM tblXlinkRestrictedFields
	WHERE user_id = @user_id
    AND ISNULL(tblXlinkRestrictedFields.franchiseuser_id,0) = @Franchiseuserid

	--open the cursor
	open cur_rs

	--fetch the first value
	FETCH NEXT FROM cur_rs INTO @restricted_field

	WHILE (@@FETCH_STATUS=0)
	BEGIN

	IF ISNULL(@restricted_field,'') <> '' AND LEN(ISNULL(@restricted_field,'')) = 8
	BEGIN
	-- check for first char as digit and replace with hex
		IF (PATINDEX('%[0-9]%', @restricted_field) = 1)
		BEGIN
		select @restricted_field = REPLACE(substring(@restricted_field, 1, 1), 
											substring(@restricted_field, 1, 1), '_x003' + 
											substring(@restricted_field, 1, 1) + '_') + RIGHT(@restricted_field,7)
		END

	SELECT @XMLString = @XMLString + '<' + @restricted_field + '>X</' + @restricted_field + '>'
	END
	-- Fetch the next value.
	FETCH NEXT FROM cur_rs INTO @restricted_field
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

	UPDATE tblXlinkRestrictedFields SET publish_date = getdate() WHERE user_id = @user_id
	AND ISNULL(tblXlinkRestrictedFields.franchiseuser_id,0) = @Franchiseuserid
		
END





