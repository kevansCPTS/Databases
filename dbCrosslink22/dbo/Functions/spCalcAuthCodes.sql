-- =============================================
-- Author:		Jay Willis
-- Create date: 10/30/2009
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[spCalcAuthCodes] 
(
	-- Add the parameters for the function here
	@four_char_code varchar(4),
	@userid int

)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result int

	-- Add the T-SQL statements to compute the return value here
	DECLARE
	@authcode as int,
	@season as int,
	@char_index as int,
	@char_code as int,
	@code_part as int,
	@auth_code as int
	select @auth_code = 0

	SELECT @season = dbo.getXlinkSeason()
--	SELECT @season = 2012

	WHILE LEN(@four_char_code) < 4
	BEGIN
		SELECT @four_char_code = '0' + @four_char_code
	END

	SELECT @char_index = 0
	WHILE (@char_index <= 3)
	BEGIN
		SELECT @char_code = dbo.GetCharacterCode(SUBSTRING(@four_char_code,@char_index+ 1,1))
		SELECT @code_part = @char_code * power(10,(3 - @char_index))
		SELECT @auth_code = @auth_code + @code_part
		SELECT @char_index = @char_index + 1
	END
	SELECT @auth_code = (@auth_code + @userid + @season - 1) * 163
	SELECT @auth_code = @auth_code + ((@auth_code % 1000000) / 10000)
	SELECT @auth_code = @auth_code + ((@auth_code % 10000) / 100)
	SELECT @Result = @auth_code % 10000

	-- Return the result of the function
	RETURN @Result
END


