-- =============================================
-- Author:		<Steve Trautman>
-- Create date: <1/30/2014>
-- Description:	<Get the user's/efin's company name, or first + last name if company is empty>
-- =============================================
CREATE FUNCTION [dbo].[udf_GetCompanyName] 
(
	@UserID int = NULL,
	@EFIN int = NULL
)
RETURNS varchar(50)
AS
BEGIN
	DECLARE @company varchar(50) = NULL,
			@fname varchar(14) = NULL,
			@lname varchar(20) = NULL;

	IF @UserID IS NOT NULL
	BEGIN
		SELECT	@company = LTRIM(RTRIM(company)),
				@fname = LTRIM(RTRIM(fname)),
				@lname = LTRIM(RTRIM(lname))
		FROM tblUser WHERE user_id = @UserID;
	END
	ELSE IF @EFIN IS NOT NULL
	BEGIN
		SELECT	@company = LTRIM(RTRIM(Company)),
				@fname = LTRIM(RTRIM(FirstName)),
				@lname = LTRIM(RTRIM(LastName))
		FROM efin WHERE efin = @EFIN;
	END

	IF @company IS NULL OR @company = ''
	BEGIN
		SET @company = LTRIM(RTRIM(@fname + ' ' + @lname));
	END

	IF @company IS NULL
	BEGIN
		SET @company = '';
	END
	
	RETURN @company
END

