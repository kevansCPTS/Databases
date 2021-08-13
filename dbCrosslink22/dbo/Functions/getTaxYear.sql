Create FUNCTION [dbo].[getTaxYear] ()
	RETURNS char(4)
AS
BEGIN
	declare @Month as integer
	declare @Day   as integer
	declare @Year  as integer

	SELECT @Month = DatePart(month, getdate()), @Day = DatePart(day, getdate()), @Year = DatePart(year, getdate())

	IF @Month > 9
	BEGIN
		SET @Year = @Year + 1
	END

	RETURN convert(char(4), @Year)
END


