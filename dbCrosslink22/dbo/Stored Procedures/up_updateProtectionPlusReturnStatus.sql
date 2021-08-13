-- =============================================
-- Author:		Charles Krebs
-- Create date: 2/23/2013
-- Description:	Updates the status of a record in BillableProtectionPlusReturn
-- =============================================
CREATE PROCEDURE [dbo].[up_updateProtectionPlusReturnStatus] 
@PrimarySSN int,
@FilingStatus char(1),
@UserID int,
@StatusID int,
@UpdatedBy varchar(50) 
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	UPDATE BillableProtectionPlusReturn
	SET StatusID = @StatusID, 
	StatusDate = GETDATE(), 
	UpdatedBy = @UpdatedBy
	WHERE PrimarySSN = @PrimarySSN
	AND FilingStatus = @FilingStatus
	AND UserID = @UserID

	IF (@@ROWCOUNT = 1)
	BEGIN
		SELECT 1 Success, 'Row Updated' Message
	END
	ELSE
	BEGIN
		SELECT 0 Success, 'Row Not Found' Message
	END

END


