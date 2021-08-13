-- =============================================
-- Author:		Charles Krebs
-- Create date: 12/24/2009
-- Description:	Reset an AES Password
-- =============================================
CREATE PROCEDURE [dbo].[peispResetAESPassword]
@aesID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE tblAES SET Reset = 'X' WHERE aesID = @aesID
END


