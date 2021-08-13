-- =============================================
-- Author:		Charles Krebs
-- Create date: 12/11/2009
-- Description: 
-- =============================================
CREATE PROCEDURE [dbo].[peispGetAESPasswords]
@user_id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT aesID, userid, siteid, aes, tstamp, reset
	FROM tblAES 
	WHERE userid = @user_id
END


