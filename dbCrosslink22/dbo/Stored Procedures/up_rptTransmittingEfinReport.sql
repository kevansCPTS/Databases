
-- =============================================
-- Author:		Sundeep Brar
-- Create date: 05/19/2020
-- Description:	Stored procedure for inteneral report > customer support report > Transmitting EFIN Report
-- =============================================
CREATE PROCEDURE [dbo].[up_rptTransmittingEfinReport]

AS

BEGIN
	declare @season smallint

	set @season = '20' + right(db_name(),2)

	select
		es.account
	,	es.efin
	,	es.[user_id]
	,	c.master_user_id MasterUserID
	,	le.LeadExecName
	,	case 
			when v.vip_stat = 'Y' then 'VIP'
			when v.vip_stat = 'P' then 'Platinum'
			else c.CustomerSize
		end CustomerSize
	,	sum(es.racs_funded) FundedBankProducts
	,	isnull(eb.BankName, es.bank_id) Bank
	,	ch.parentAccount ParentAccount
	from dbCrosslinkGlobal.dbo.efin_stats es join dbCrosslinkGlobal.dbo.customer c on es.account = c.account
		join dbCrosslinkGlobal.dbo.vwLeadExecutive le on c.account = le.AccountCode 
		left join EFINBank eb on es.bank_id = eb.EFINBankID 
		left join dbCrosslinkGlobal.dbo.vip v on c.idx = v.idx
		left join dbCrosslinkGlobal.dbo.tblCustomerHierarchy ch on es.account = ch.childAccount and ch.season = @season
	where 
		es.season = @season and es.racs_funded > 0
	group by
		es.efin
	,	es.[user_id]
	,	es.bank_id
	,	es.account 
	,	le.LeadExecName
	,	eb.BankName
	--,	c.CustomerSize
	--,	v.vip_stat
	,	case 
			when v.vip_stat = 'Y' then 'VIP'
			when v.vip_stat = 'P' then 'Platinum'
			else c.CustomerSize
		end
	,	c.master_user_id
	,	ch.parentAccount
	ORDER BY
		es.account
	,	es.efin
	,	ch.parentAccount

END

