
-- =============================================
-- Author:		Sundeep Brar
-- Create date: 05/19/2020
-- Description:	Stored procedure for inteneral report > customer support report > Special Accounts Report
-- =============================================
CREATE PROCEDURE [dbo].[up_rptSpecialAccountsReport]

AS

declare @sqlstr                     nvarchar(500)
declare @season                     smallint
declare @sSeasonPs                    char(2)

create table #cagree (
    account                         varchar(8)
,   AgreeToPassthroughTerms         bit
,   AgreeToEFTerms                  bit
,   CONSTRAINT cagree_pk PRIMARY KEY CLUSTERED
    ( 
        account
    )
)

    set nocount on

    set @season = '20' + right(db_name(),2)
	set @sSeasonPs = right(db_name(),2) - 1

    set @sqlstr = 'select 
                        ca.account
                    ,	ca.AgreeToPassthroughTerms AgreeToAddon
                    ,	ca.AgreeToEFTerms AgreeToEFile
                    from 
                        dbCrosslink' + @sSeasonPs + '.dbo.CustomerAgreements ca'

    insert #cagree
        exec sp_executeSql @sqlstr 

/*
	select
		aap.account
	,	max(case when tag = 'AUD' then 1 else 0 end) PP
	,	max(case when tag = 'CAD' then 1 else 0 end) 'CADR+'
	into
		#tempTable
	from
		tblAccountAncillaryProduct aap
		join dbCrosslinkGlobal.dbo.customer c on aap.account = c.account
	where
		aap.agreeToParticipate = 1 and aap.agreeToTerms = 1 and aap.tag in ('AUD', 'CAD')
	group by
		aap.account
*/

	select
		c.account
	,	c.company
	,	le.LeadExec
	,	isnull(v.vip_stat, '') vip_stat
	,	c.CustomerSize
	,	c.co_brander
	,	c.service_bureau
	,	c.AllowFranchiseUsers
	,	c.TechSupportProvider
	--,	aap.PP PP
    ,   case when aap.account is not null then 1 else 0 end PP
	--,	aap.[CADR+] CADR_
	,	c.ProtectedCustomer
	,	c.SBName
	,	atfp.CrosslinkTransmitterFee
	,	atfp.MSOTransmitterFee
	,	atfp.NonFinancialTransmitterFee
	,	refundo.TechFee RefundoTechFee
	,	republic.TechFee RepublicTechFee
	,	TPG.TechFee TPGTechFee
	,	TPGW.TechFee TPGWorldTechFee
	,	refund.TechFee RefundTechFee
	,	ch.parentAccount ParentAccount
	,	ca.AgreeToPassthroughTerms AgreeToAddon
	,	ca.AgreeToEFTerms AgreeToEFile
	from
		dbCrosslinkGlobal.dbo.customer c join dbCrosslinkGlobal.dbo.leads l on c.idx = l.idx
		left join dbCrosslinkGlobal.dbo.vwLeadExecutive le on l.idx = le.LeadIndex
		--left join #tempTable aap on c.account = aap.account
		left join dbCrosslinkGlobal.dbo.vip v on c.idx = v.idx
		left join dbCrosslinkGlobal.dbo.AccountTransmitterFeePrice atfp on c.account = atfp.Account and atfp.Season = @season
		left join dbCrosslinkGlobal.dbo.AccountTechFeePrice refundo on c.account = refundo.Account and refundo.Season = @season and refundo.BankID = 'F'
		left join dbCrosslinkGlobal.dbo.AccountTechFeePrice republic on c.account = republic.Account and republic.Season = @season and republic.BankID = 'R'
		left join dbCrosslinkGlobal.dbo.AccountTechFeePrice TPG on c.account = TPG.Account and TPG.Season = @season and TPG.BankID = 'S'
		left join dbCrosslinkGlobal.dbo.AccountTechFeePrice TPGW on c.account = TPGW.Account and TPGW.Season = @season and TPGW.BankID = 'W'
		left join dbCrosslinkGlobal.dbo.AccountTechFeePrice refund on c.account = refund.Account and refund.Season = @season and refund.BankID = 'V'
        left join dbo.tblAccountAncillaryProduct aap on c.account = aap.account
            and aap.tag = 'AUD'
            and aap.agreeToParticipate = 1 
            and aap.agreeToTerms = 1
		left join dbCrosslinkGlobal.dbo.tblCustomerHierarchy ch on c.account = ch.childAccount and ch.season = @season
		--left join dbo.CustomerAgreements ca on c.account = ca.Account
		left join #cagree ca on c.account = ca.Account
	where
		c.service_bureau in ('Y', 'X')
		or v.vip_stat in ('Y', 'P')
        or aap.account is not null
		--or aap.PP = 1
		--or aap.[CADR+] = 1
	order by
		c.account


    drop table #cagree

