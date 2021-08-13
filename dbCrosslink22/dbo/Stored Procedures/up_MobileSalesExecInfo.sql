
CREATE PROCEDURE [dbo].[up_MobileSalesExecInfo] --'RIVEDG'
	@AccountId		VARCHAR(8)
AS

SET NOCOUNT ON

SELECT fullname,
	contact_number,
	ext,
	email
FROM tblsalesexecinfo WHERE initials IN
	(SELECT logins.initials FROM leads, customer, logins
	WHERE leads.idx = customer.idx
	AND leads.lead_exec = logins.initials
	AND customer.account = @AccountId)

