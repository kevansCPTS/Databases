-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetUnregisteredOffices]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Year char(4)

	SELECT @Year = dbo.getTaxYear()

	SELECT	u.Account, 
			u.user_id, 
			e.efin, 
			Bank_name = '' ,
			IsNull(e.master, 0),
			l.lead_exec,
			c.CustomerSize,
			isnull(vip.vip_stat, '') vip_stat
	FROM	dbCrosslinkGlobal..tblUser u with (nolock)
	INNER JOIN efin e with (nolock) on e.userId = u.user_id
	INNER JOIN dbCrossLinkGlobal..customer c with (nolock) on c.account = u.account
	INNER JOIN dbCrosslinkGlobal..leads l with (nolock) on l.idx = c.idx
	
	LEFT JOIN dbcrosslink..efin oe on oe.efin = e.efin 	AND oe.efin_stat = 'A'
	LEFT JOIN vip (nolock) ON vip.idx = l.idx
	WHERE	u.Account IN (
				-- Get all the Accounts that have purchased this year's software.
				SELECT Account
				FROM	dbCrosslinkGlobal..orders o with (nolock)
				INNER JOIN dbCrosslinkGlobal..ord_items oi with (nolock) ON o.ord_num = oi.ord_num
				WHERE oi.prod_cd LIKE 'US%'
				AND o.season = convert(char(4), @Year)
				AND o.ord_stat IN ('A', 'C')
	)
	AND e.efin NOT IN 
		(SELECT DISTINCT EFIN FROM vwLatestApplicationResponse WHERE Registered in ('A', 'C'))
	order by u.account, e.efin
END


