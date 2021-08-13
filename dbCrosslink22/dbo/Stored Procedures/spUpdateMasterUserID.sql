
CREATE PROCEDURE [dbo].[spUpdateMasterUserID] 
	-- Add the parameters for the stored procedure here
	@accountid varchar(8)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE	@usersettingsid int

	DECLARE updatecur_rs CURSOR fast_forward
	FOR
	SELECT usersettings_id
	FROM   tblXlinkUserSettings
	WHERE  account_id = @accountid and publish_date is not null
	OPEN updatecur_rs;
	FETCH NEXT FROM updatecur_rs INTO @usersettingsid;
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	BEGIN TRY
		EXEC spOfficeSettings @usersettingsid;
	END TRY		
	BEGIN CATCH
		SELECT ERROR_NUMBER() AS ErrorNumber;
	END CATCH;
	FETCH NEXT FROM updatecur_rs INTO @usersettingsid;
	END;
	CLOSE updatecur_rs;
	DEALLOCATE updatecur_rs;
END




