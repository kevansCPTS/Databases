-- =============================================
-- Author:		Jay Willis
-- Create date: 10/30/2009
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[getCharacterCode] 
(
	-- Add the parameters for the function here
	@test char(1)
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result int

	-- Add the T-SQL statements to compute the return value here
	IF ISNUMERIC(@test) = 1
		SELECT @Result =  ('' + @test)
	ELSE
		SELECT @Result = (ASCII(@test)-65 + 1) % 16


	-- Return the result of the function
	RETURN @Result

END


