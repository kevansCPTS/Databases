-- =============================================
-- Author:		Charles Krebs & Tim Gong
-- Create date: 12/10/2010
-- Description:	Retrieve a list of Live Users which have yet to be contacted for the season.
-- =============================================
CREATE PROCEDURE [dbo].[spGetUncontactedUsers] 
	-- Add the parameters for the stored procedure here
	@p1 int = 0, 
	@p2 int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select distinct
		tblUser.Account,
		tblUser.user_id 'User ID', 
		tblUser.phone 'Phone Number',
		tblUser.fname 'First Name',
		tblUser.lname 'Last Name',
		appResponse.EROTranFee / 100 'ERO Tran Fee',
		(CASE WHEN customer.service_bureau is null THEN ' ' ELSE customer.service_bureau END) 'Is Service Bureau?',
		(CASE WHEN customer.co_brander is null THEN ' ' ELSE customer.co_brander END) 'Is Co-Branded?'
	from tblUser
		LEFT JOIN efin ON tblUser.user_ID = efin.userID
		LEFT JOIN customer on customer.account = tblUser.account
		LEFT JOIN vwLatestApplicationResponse appResponse ON appResponse.Efin = efin.Efin 
					AND appResponse.BankID = efin.SelectedBank
	where tblUser.contacted_by is null
	and tblUser.status = 'L'
	and tblUser.user_id not in ( select quantity from history
						where action_cd='S' and result_cd='2') 
	order by tblUser.Account, tblUser.User_ID

END


