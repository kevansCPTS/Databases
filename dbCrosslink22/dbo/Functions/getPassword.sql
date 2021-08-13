-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[getPassword] 
(
	-- Add the parameters for the function here
	@UserID char(6)
)
RETURNS char(8)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @UserNum int, @cset char(35), @j smallint, @x int, @y int, @z int
	DECLARE @Password char(8)

	SELECT @Password = '', @UserNum = convert(int, @UserID)

	SET @z = 41985
	If @UserNum > 51140 
		SET @z = 35985

	IF @UserNum > 59000
		SET @z = 25985

	IF @UserNum > 82000
		SET @z = 15985

	SELECT @cset = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXZY', @x = @userNum * @z, @j = 0

	WHILE @x > 0 and @j < 8
	BEGIN
		SET @y = @x % 31
		SET @x = @x / 31
		SET @j = @j + 1

		SELECT @Password = substring(@Password, 1, @j -1) + substring(@cset, @y + 1, 1)
	END

	RETURN @Password
END


