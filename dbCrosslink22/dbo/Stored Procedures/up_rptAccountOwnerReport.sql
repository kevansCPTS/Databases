
-- =============================================
-- Author:		Sundeep Brar
-- Create date: 05/20/2020
-- Description:	Stored procedure for inteneral report > customer support report > Account Owner Report
-- =============================================
CREATE PROCEDURE [dbo].[up_rptAccountOwnerReport]

AS

BEGIN

	declare @clist table(
		account varchar(8)
	,	aType tinyint
	)

	declare @season smallint

	set @season = '20' + right(DB_NAME(),2)

	set nocount on

    insert @clist
        select distinct
            dfa.Account 
        ,   2
        from
            dbCrosslinkGlobal.dbo.tblDailyFilingActivity dfa 
        where
            dfa.Season = @season - 1
            and (dfa.Efiles > 0
                or dfa.SubmittedBankProducts > 0)


    insert @clist
        select distinct
            pl.Account
        ,   1
        from 
            dbCrosslinkGlobal.dbo.tblProductLicense pl left join @clist c on pl.Account = c.account
        where
            pl.season = @season
            and pl.StatusId = 1
            and pl.ord_num > 0
            and c.account is null




/*
	insert @clist
		select distinct
			o.account
		,	1
		from
			dbo.orders o join dbo.ord_items oi on o.ord_num = oi.ord_num 
				and o.season = @season 
				and oi.prod_cd in ('VTAX', 'USTP')
				and o.ord_stat in ('A', 'C')
				and o.account not in (
					                    select distinct
						                    o.Account
					                    from
						                    dbo.orders o join dbo.ord_items oi on o.ord_num = oi.ord_num
							                    and o.season between (@season - 2) and (@season - 1)
							                    and oi.prod_cd in ('VTAX', 'USTP')
							                    and o.ord_stat in ('A', 'C')
							                    and o.ord_tot > 0
					                    union select
						                    yfa.account 
					                    from 
						                    dbCrosslinkGlobal..tblYearlyFilingActivity yfa
					                    where 
						                    season < @season 
						                    and season >= @season - 2
						                    and FundedBankProducts > 0
				                    )

	insert @clist
		select distinct
			yfa.Account
		,   2
		from
			dbCrosslinkGlobal.dbo.tblYearlyFilingActivity yfa left join @clist c on yfa.Account = c.account
		where
			yfa.Season = @season - 1 
			and c.account is null   	
*/

	select
		cu.account
	,	le.LeadExecName
	,	case v.vip_stat
			when 'Y' then 'VIP'
			when 'P' then 'Platinum'
			else ''
		end vip_stat
	,	cu.CustomerSize
	,	cu.OwnerFName
	,	cu.OwnerLName
	,	cu.OwnerPhone
	,	cu.OwnerCell
	,	cu.OwnerEmail
	,	c.aType
	,	ch.parentAccount
	from
		dbCrosslinkGlobal.dbo.customer cu join @clist c on cu.account = c.account
		join dbCrosslinkGlobal.dbo.vwLeadExecutive le on cu.Account = le.AccountCode
		left join dbCrosslinkGlobal.dbo.vip v on cu.idx = v.idx
		left join dbCrosslinkGlobal.dbo.tblCustomerHierarchy ch on cu.account = ch.childAccount
	order by
		cu.account

END

