-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGenerateNewUser]
		@UserID char(6),
		@CompanyName varchar(34), 
		@FirstName varchar(14),
		@LastName varchar(20),
		@Address varchar(34),
		@City varchar(20),
		@State varchar(2),
		@Zip varchar(10),
		@Email varchar(50),
		@PhoneNumber varchar(10),
		@FaxNumber varchar(10),
		@Bank char(1),
		@EROTranFee money,
		@EFIN char(6),
		@EHFName varchar(14),
		@EHLName varchar(20),
		@Account char(8), 
		@MastEFIN char(6),
		@Svcb_ID char(6)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE	@iSQL varchar(max), @Password char(8), @param char(10)

	-- Get Password based off of UserID.
	SELECT @Password = dbo.getPassword(@UserID)

	PRINT @Password
	--PRINT @Svcb_ID
	/*
	-- Get hold_flag and status from the master user.
	SET @iSQL = 'SELECT * FROM OPENQUERY(rh1, ''select hold_flag, status from user where user_id = ' + @Svcb_ID + ''')'

	-- Create temporary table.
	CREATE TABLE #tempGetMasterInfo (HoldFlag char(1), Status char(1))

	-- Insert into temporary table.
	INSERT #tempGetMasterInfo
	EXEC (@iSQL)

	-- Pull back the values.
	SELECT @HoldFlag = HoldFlag, @Status = Status
	FROM	#tempGetMasterInfo

	-- Drop the table.
	DROP TABLE #tempGetMasterInfo
	*/
	-- Insert into the user table.
	SET @iSQL = 'insert into user (user_id, account, bank_id, mast_efin, hold_flag, status, passwd, ' 
		+ 'edit_dt, web_passwd, email, fname, lname, phone, fax, company, addr1, city, state, '
		+ 'zip, prep, edit_by, sb_id) values (' + RTrim(@UserID) + ', ''' + RTrim(@Account) + ''', ''' + @Bank 
		+ ''', ''' + @MastEFIN + ''', ''N'', ''A'', ''' + RTrim(@Password) + ''', ''' 
		+ convert(char(10), getdate(), 101) + ''', ''Password'', ''' + @Email + ''', ''' 
		+ Replace(@FirstName, '''', '''''') + ''', ''' + Replace(@LastName, '''', '''''') + ''', ''' 
		+ @PhoneNumber + ''', ''' + ''', ''' + Replace(@CompanyName, '''', '''''') + ''', ''' + @Address 
		+ ''', ''' + Replace(@City, '''', '''''') + ''', ''' + @State + ''', ''' + @Zip 
		+ ''', ''' + 'WP' + ''', ''portal'', ' + RTrim(@Svcb_ID) + ')'

	EXEC (@iSQL) at rh1;

	PRINT '@iSQL: ' + IsNull(@iSQL, 'Nothing')

	-- Send Admin message for User record.
	SET @param = 'N' + @Bank + dbo.PadString(@MastEFIN, '0', 6)
	EXEC spInsertAdminMessage @UserID, 'A', @param, 'portal'

	-- Send Admin message for Password.
	EXEC spInsertAdminMessage @UserID, 'P', @Password, 'portal'

	-- Add to soft_user by queueing, US, TP and HP packages for new user.
	EXEC spQueuePackage @UserID, 'US'
	EXEC spQueuePackage @UserID, 'TP'
	EXEC spQueuePackage @UserID, 'HP'
END


