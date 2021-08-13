-- =============================================
-- Author:		Chuck Robertson
-- Create date: 12/09/2009
-- Description:	This procedure will queue a given package ID for the 
--				given User ID.
-- =============================================
CREATE PROCEDURE [dbo].[spQueuePackage]
	@userID char(6),
	@pkgID  char(4)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE	@fileName char(8), @pkgVer smallint, @softUserID char(6)
	DECLARE @iSQL varchar(max)

	-- Pull back User Id from soft_user.
	SET @iSQL = 'SELECT * FROM OPENQUERY(rh1, ''select user_id from soft_user where user_id = '
		+ RTrim(@UserID) + ' and pkg_id = ''''' + RTrim(@pkgID) + ''''''')'

	PRINT @iSQL

	-- Create temporary table.
	CREATE TABLE #tempSoftUser (UserID char(6))

	-- Insert into table.
	INSERT #tempSoftUser
	EXEC (@iSQL)

	-- Pull back information.
	SELECT @softUserID = UserID
	FROM #tempSoftUser

	PRINT '@softUserID: ' + IsNull(@softUserID, 'Nothing')

	-- Drop table.
	DROP TABLE #tempSoftUser

	IF @softUserID IS NULL
	BEGIN
		-- Insert into the table.
		SET @iSQL = 'insert into soft_user values (' + RTrim(@UserID) + ', ' + RTrim(@pkgID) + ', 0)'

		-- EXEC (@iSQL) at rh1
		PRINT '@iSQL: ' + IsNull(@iSQL, 'Nothing')
	END

	-- Get base package version number.
	SET @iSQL = 'SELECT * FROM OPENQUERY(rh1, ''select pkg_ver from soft_rel where rel_stat = ''''-'''''
		+ ' and pkg_id = ''''' + RTrim(@pkgID) + ''''''')'

	PRINT '@iSQL: ' + @iSQL

	-- Create temporary table.
	CREATE TABLE #tempGetPkgVersion (pkgVer smallint)

	-- Insert into temporary table.
	INSERT #tempGetPkgVersion
	EXEC (@iSQL)

	-- Select back the values.
	SELECT @pkgVer = IsNull(pkgVer, -1)
	FROM #tempGetPkgVersion

	-- Drop temporary table.
	DROP TABLE #tempGetPkgVersion

	PRINT '@pkgVer: ' + convert(char(4), @pkgVer)

	-- Build SQL statement to get all versions of the given package.
	SET @iSQL = 'SELECT * FROM OPENQUERY(rh1, ''select file_name from soft_rel where rel_stat = ''''R''''' + 
		+ ' and pkg_id = ''''' + RTrim(@pkgID) + ''''' and pkg_ver > ' + RTrim(convert(char(3), @pkgVer)) + ''')'

	PRINT '@iSQL: ' + @iSQL

	-- Create temporary table.
	CREATE TABLE #tempGetPkgFiles (fileName char(9))

	-- Insert records into temporary table.
	INSERT #tempGetPkgFiles
	EXEC (@iSQL)

	-- Declare cursor to loop through records.
	DECLARE cur_PkgFiles CURSOR FOR
		SELECT fileName FROM #tempGetPkgFiles

	-- Open the cursor.
	OPEN cur_PkgFiles

	-- Fetch records.
	FETCH NEXT FROM cur_PkgFiles INTO @fileName

	PRINT '@fileName: ' + IsNull(@fileName, 'Nothing')

	-- Loop through all records.
	WHILE (@@FETCH_STATUS=0)
	BEGIN
		
		EXEC spInsertAdminMessage @UserID, 'F', @fileName, 'portal'

		-- Get next record.
		FETCH NEXT FROM cur_PkgFiles INTO @fileName

		PRINT '@fileName: ' + IsNull(@fileName, 'Nothing')
	END

	-- Close cursor.
	CLOSE cur_PkgFiles

	-- Clean up memory.
	DEALLOCATE cur_PkgFiles

	-- DROP TABLE.
	DROP TABLE #tempGetPkgFiles

END


