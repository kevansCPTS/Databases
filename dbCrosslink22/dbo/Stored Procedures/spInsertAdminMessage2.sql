-- =============================================
-- Author:		Chuck Robertson
-- Create date: 12/09/2009
-- Description:	Insert a Central Site Admin message
-- Updated: 12/6/2010 Charles Krebs	
--	Synced with Development -- Dropped reference to external database server rh1
-- Updated 1/7/2011 Jay Willis
--  Fixed insert statement, switched @param and @UserID to proper places
-- =============================================
CREATE PROCEDURE [dbo].[spInsertAdminMessage2]
	@userID		char(6),
	@msgType	char(1),
	@param		char(10),
	@requestor	char(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Pad @userID to 6 digits
	select @userID = dbo.padstring(@userID,'0',6)

	-- Send Admin message for User record.
	insert into admin (delivered, req_type, ssn, param, dt, requestor) values
		(' ', @msgType, @UserID, @param, getdate(), @requestor)

END


