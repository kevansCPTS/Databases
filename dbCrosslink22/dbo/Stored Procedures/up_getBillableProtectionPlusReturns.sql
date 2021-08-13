-- =============================================
-- Author:		Charles Krebs
-- Create date: 2/25/2013
-- Description:	Retrieves the details for BillableProtectionPlusReturn
-- records for the specified Account with the specified StatusID
-- Update 3/14/2013
--	Added optional UserID parameter
-- =============================================
CREATE PROCEDURE [dbo].[up_getBillableProtectionPlusReturns] 
	@Account varchar(8),
	@UserID int = null
AS
BEGIN
	IF (@UserID is null)
	BEGIN
		SELECT PPR.PrimarySSN, PPR.FilingStatus, PPR.UserID, 
			RM.PrimaryFirstName, RM.PrimaryLastName, RM.City, RM.State, 
			PPR.StatusID,
		IsNull(SUM(Cast(OTC.Amount AS money) / 100), 0) 'OTCPayments', 
		RowID
		FROM BillableProtectionPlusReturn PPR (nolock)
		INNER JOIN dbCrosslinkGlobal..tblUser (nolock) ON tblUser.user_id = PPR.UserID
		INNER JOIN tblReturnMaster RM (nolock) ON RM.PrimarySSN = PPR.PrimarySSN
				AND RM.FilingStatus = PPR.FilingStatus AND RM.UserID = PPR.UserID
		LEFT JOIN tblOTCPayments OTC (nolock) ON PPR.PrimarySSN = OTC.PrimaryId
				AND PPR.FilingStatus = OTC.FilingType
				AND PPR.UserID = OTC.UserID
		WHERE tblUser.account = @Account 
			AND PPR.OrderNumber is null
		GROUP BY PPR.PrimarySSN, PPR.FilingStatus, PPR.UserID, 
			RM.PrimaryFirstName, RM.PrimaryLastName, RM.City, RM.State, 
			StatusID, RowID
	END
	ELSE
	BEGIN
		SELECT PPR.PrimarySSN, PPR.FilingStatus, PPR.UserID, 
			RM.PrimaryFirstName, RM.PrimaryLastName, RM.City, RM.State, 
			PPR.StatusID,
		IsNull(SUM(Cast(OTC.Amount AS money) / 100), 0) 'OTCPayments', 
		RowID
		FROM BillableProtectionPlusReturn PPR (nolock)
		INNER JOIN dbCrosslinkGlobal..tblUser (nolock) ON tblUser.user_id = PPR.UserID
		INNER JOIN tblReturnMaster RM (nolock) ON RM.PrimarySSN = PPR.PrimarySSN
				AND RM.FilingStatus = PPR.FilingStatus AND RM.UserID = PPR.UserID
		LEFT JOIN tblOTCPayments OTC (nolock) ON PPR.PrimarySSN = OTC.PrimaryId
				AND PPR.FilingStatus = OTC.FilingType
				AND PPR.UserID = OTC.UserID
		WHERE tblUser.account = @Account 
			AND tblUser.user_id = @UserID
			AND PPR.OrderNumber is null
		GROUP BY PPR.PrimarySSN, PPR.FilingStatus, PPR.UserID, 
			RM.PrimaryFirstName, RM.PrimaryLastName, RM.City, RM.State, 
			StatusID, RowID
	END

END
