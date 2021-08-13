-- =============================================
-- Author:		Colby Leiske
-- Create date: 08/06/2018
-- Description:	Adds a userid and secret association for XeroBridge to reference
-- =============================================
CREATE PROCEDURE spXeroBridgeInsertSecret 
	-- Add the parameters for the stored procedure here
	@UserID nvarchar(50),
	@Secret nvarchar(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT tblXeroBridgeSecrets (UserID, Secret, Timestamp) VALUES (@UserID, @Secret, GETDATE())
END

