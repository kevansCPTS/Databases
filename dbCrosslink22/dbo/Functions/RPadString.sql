CREATE FUNCTION [dbo].[RPadString]
(
	@Seq varchar(16),
	@PadWith char(1),
	@PadLength int
)
	RETURNS varchar(16) 
AS
BEGIN
	declare @curSeq varchar(16)
	SELECT @curSeq = RTRIM(@Seq) + ISNULL(REPLICATE(@PadWith, @PadLength - len(ISNULL(@Seq ,0))), '')
	RETURN @curSeq
END


