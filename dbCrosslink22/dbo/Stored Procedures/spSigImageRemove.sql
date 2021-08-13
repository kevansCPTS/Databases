-- =============================================
-- Author:		Edvin Eshagh
-- Create date: 8/10/2009
-- Description:	Retrieve Signature images
-- =============================================
CREATE PROCEDURE [dbo].[spSigImageRemove] 

	@returnId          INT,
	@recordsDeleted	   INT OUTPUT

AS
BEGIN

	DECLARE @taxpayerSignature bit, @spouseSignature bit, @hasSpouse bit	
	SET NOCOUNT ON;

	SELECT 
			@taxpayerSignature = CASE WHEN s.taxpayerSignature = null THEN 0 ELSE 1 END
		,	@spouseSignature = CASE WHEN s.spouseSignature = null THEN 0 ELSE 1 END 
		,	@hasSpouse = f.spouse
	FROM tblSignatureImage s 
	INNER JOIN tblForms f ON f.ReturnID = s.returnId
	WHERE s.ReturnId = @returnId

	IF @taxpayerSignature = 1 AND ( NOT @hasSpouse = 0  OR ( @hasSpouse = 1 AND @spouseSignature = 1) )
	  BEGIN
		DELETE FROM tblSignatureImage WHERE returnId=@returnId;
		SET @recordsDeleted = 1
	  END
	ELSE
		SET @recordsDeleted = 0

END
