-- =============================================
-- Author:		Charles Krebs
-- Create date: 2/25/2013
-- Description:	Retrieves summary details regarding Approved, unpaid Protection Plus Returns
-- =============================================
CREATE PROCEDURE [dbo].[up_getApprovedProtectionPlusSummary] 
	@Account varchar(8)
AS
BEGIN

	DECLARE @ReturnCount int
	DECLARE @ReturnPrice money
	DECLARE @TotalPrice money


	SELECT @ReturnCount = COUNT(*)
	FROM BillableProtectionPlusReturn PPR (nolock)
		INNER JOIN dbCrosslinkGLobal..tblUser (nolock) ON tblUser.user_id = PPR.UserID
	WHERE tblUser.account = @Account
	AND PPR.StatusID = 2 
	AND PPR.OrderNumber is null


	SELECT @ReturnPrice = uprice
	FROM dbCrosslinkGlobal..ord_stock 
	WHERE prod_cd = 'XP' 
	AND season = dbo.getXlinkSeason()

	SET @TotalPrice = @ReturnCount * @ReturnPrice

	SELECT @ReturnCount ReturnCount, @ReturnPrice ReturnPrice, @TotalPrice TotalPrice
END


