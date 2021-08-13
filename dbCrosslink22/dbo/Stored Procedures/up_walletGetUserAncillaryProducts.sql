---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		jdaniel
-- Create date: 2020-09-03
-- Description:	Pull back information on ERO ancillary product by wallet token 
-- =============================================
CREATE PROCEDURE up_walletGetUserAncillaryProducts 
	-- Add the parameters for the stored procedure here
	@WalletToken    char(32)

AS
BEGIN

	DECLARE @Account varchar(8)
	DECLARE @UserId  int
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


		select
				a.tag
				, a.account
				, a.userID
				, a.eroAddonFee
				, c.[name]
				, b.createdDate
		from
		dbCrosslinkGlobal.dbo.tblWallet w join dbo.tblXlinkUserProducts a on w.account = a.account
		and w.userId = a.userID
		and w.walletToken = @wallettoken
		join dbo.tblUserAncillaryProduct b on a.userID = b.UserID
		and a.tag = b.ProductTag
		join dbo.tblAncillaryProduct c on a.tag = c.tag

	
   
END