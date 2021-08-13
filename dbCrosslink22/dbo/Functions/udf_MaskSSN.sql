

CREATE FUNCTION [dbo].[udf_MaskSSN]
(
	@SSN int
)
	RETURNS char(4) 
AS
BEGIN
	RETURN substring(dbo.PadString(@SSN,'0',9), 6, 4)
END


