
--Return the first space-delimited word, or just the rest of the string if no spaces
CREATE FUNCTION [dbo].[udfGetFirstWord](
    @myString VARCHAR(MAX)
	)
RETURNS 
    VARCHAR(MAX) 
AS
BEGIN

	DECLARE @first_space_pos int = 1,
			@len int = 0,
			@word_len int = NULL;

	SET @myString = LTRIM(RTRIM(@myString))
	SET @len = LEN(@myString)
	IF @len IS NULL OR @len = 0
		RETURN NULL
	--find the end of the first word at the end of the string or at the first space char
	SET @first_space_pos = CHARINDEX(' ', @myString, 2) --we already know we have one non-space char at position 1, so start at 2
	SET @word_len = CASE WHEN @first_space_pos = 0 THEN @len ELSE @first_space_pos - 1 END
	RETURN SUBSTRING(@myString, 1, @word_len)
END

