-- =============================================
-- Author:		Charles Krebs, Sreenivas Chikka, Karl Malbrain
-- Create date: 8/16/2011
-- Description:	Determine whether the indicated state package 
-- is authorized for release to the indicated UserID.  If so, 
-- release the software to the user.  Return variables indicating
-- the User's status with the package.
-- 12/20/2012 replaced hardcode season dbo.getXlinkSeason()  Tim Gong
-- Updated procedure 
-- to always release the package updates, even if the user was already in 
-- the soft_user table Charles Krebs 8/12/2013
-- =============================================
CREATE PROCEDURE [dbo].[spReleaseStatePackage]
@userID int,
@stateCode char(2),
@releaseFlag int,
@lastReleaseDate datetime = null output, 
@softwareReleasedToUser bit = null output, 
@releaseAuthorized bit = null output, 
@packageReleased bit = null output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CROSSLINK_SEASON int
	
	SET @CROSSLINK_SEASON = dbo.getXlinkSeason()

	IF (Exists (SELECT * FROM soft_user WHERE User_ID = @userID AND pkg_id = @stateCode))
	BEGIN
		SET @softwareReleasedToUser = 1
	END
	ELSE 
	BEGIN
		SET @softwareReleasedToUser = 0
	END

	IF (@softwareReleasedToUser = 1 OR Exists (SELECT *
		FROM ord_items
		INNER JOIN orders ON ord_items.ord_num = orders.ord_num
		WHERE ord_items.prod_cd = 'ASTP'
		AND orders.season = @CROSSLINK_SEASON
		AND orders.ord_stat in ('A', 'C')
		AND orders.user_id = @userID))
	BEGIN
		SET @releaseAuthorized = 1
	END
	ELSE
	BEGIN
		SET @releaseAuthorized = 0
	END

	IF (Exists(SELECT * FROM soft_rel WHERE pkg_id = @stateCode AND rel_stat = 'R'))
	BEGIN
		SET @packageReleased = 1
	END
	ELSE
	BEGIN
		SET @packageReleased = 0
	END


	IF (@releaseAuthorized = 1 AND @releaseFlag = 1)
	BEGIN
		IF (@softwareReleasedToUser = 0)
		BEGIN
		-- Release software
			INSERT INTO soft_user (user_id, pkg_id, pkg_ver) VALUES (@userID, @stateCode, 0)
			SET @softwareReleasedToUser = 1
		END
		
		DECLARE @fileName varchar(8)

		DECLARE VersionCursor CURSOR
		FOR SELECT file_name FROM soft_rel WHERE pkg_id = @stateCode AND rel_stat = 'R' ORDER BY pkg_ver
		OPEN VersionCursor

		FETCH NEXT FROM VersionCursor INTO @fileName

		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO Admin 
			(delivered, req_type, param, ssn, dt, requestor) 
			VALUES 
			(' ', 'F', @fileName, @userID, getDate(), 'self');
			FETCH NEXT FROM VersionCursor INTO @fileName
		END
		CLOSE VersionCursor
		DEALLOCATE VersionCursor
		
	END

	SELECT @lastReleaseDate = MAX(admin.dt)
	FROM admin
		INNER JOIN soft_rel ON admin.param = soft_rel.file_name
	WHERE req_type = 'F' AND ssn = @userID
	AND soft_rel.pkg_id = @stateCode
		

	SELECT @lastReleaseDate LastReleaseDate, 
		@softwareReleasedToUser SoftwareReleasedToUser, 
		@releaseAuthorized ReleaseAuthorized, 
		@packageReleased PackageRelease
END

