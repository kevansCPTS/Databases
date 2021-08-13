

CREATE   PROCEDURE [dbo].[up_GetBusinessReturnsForFetchByAccount] 
	@Account varchar(8),
	@ClientID varchar(200),
	@Max	integer
AS

declare @includedAccounts table(
	account varchar(50)
);

declare @userIDs table(
	userID int
);

	set nocount on

	-- get all accounts
	insert @includedAccounts
		select
			ch.childAccount
		from	
			dbCrosslinkGlobal.dbo.tblCustomerHierarchy ch
		where
			ch.parentAccount = @Account
			and ch.season = dbo.getXlinkSeason()
		union select 
			@Account account;

	-- get last change ID
	declare @changeID int = (select Change_ID from WebserviceBusinessAccountDiff where account = @Account and ClientId = @ClientID)
	
	select top (@Max)
	      t.primaryId
		, t.subType
		, t.ein
		, t.corpType
		, t.businessName
		, t.UserID
		, t.efin
		, t.ptin
		, t.PaidPreparerID
		, t.returnStatus
		, t.returnStatusDate
		, t.netIncome
		, t.refund
		, t.balanceDue
		, t.preparationFee
		, t.state
		, t.ChangeID as 'LastChangeID'
	from (
			select 
			  corp.primid AS primaryId
			, corp.subType
			, ISNULL(corpReturn.PrimaryEIN, e.ein) AS ein
			, CASE corp.corp 
				WHEN 1 THEN CAST('1065' AS varchar)
				WHEN 2 THEN CAST('1120S' AS varchar)
				WHEN 3 THEN CAST('1120' AS varchar)
				WHEN 4 THEN CAST('1041' AS varchar)
				WHEN 5 THEN CAST('990' AS varchar)
				ELSE
					CAST(corp.corp  AS varchar)
			   END AS corpType
			, corp.pri_fname AS businessName
			, corp.efin
			, corp.ptin
			, corpReturn.PaidPreparerID
			, corp.irs_acc_cd AS returnStatus
			, corp.irs_ack_dt AS returnStatusDate
			, corp.tot_inc AS netIncome
			, corp.refund AS refund
			, corp.bal_due AS balanceDue
			, corpReturn.PrepFee AS preparationFee
			, corp.stateid AS state
			, rfs.UserID
			, rfs.ChangeID
			, rfs.ChangeDTTM
			, row_number() over(partition by rfs.PrimaryID, rfs.StateID, rfs.SubType order by rfs.ChangeDTTM desc) as rowNum
			from 
				@includedAccounts ia join dbCrosslinkGlobal.dbo.tblUser u on ia.account = u.account
				join dbo.tblFetchSvcBusRtnStatus rfs on u.[user_id] = rfs.UserID
					and (@changeID is null or rfs.ChangeID > @changeID)
				join tblCorpmast corp on rfs.PrimaryID = corp.primid and rfs.StateID = corp.stateid and rfs.SubType collate SQL_Latin1_General_CP1_CS_AS = corp.subType
				left join efin e on corp.efin = e.efin and corp.userid = e.UserID
				left join tblCorpReturnMaster corpReturn on e.ein = corpReturn.PrimaryEIN and corp.userid = corpReturn.UserID and corp.corp = corpReturn.CorpType
		) t 
	where 
		t.rowNum = 1 --most recent between tblTaxMast and tblReturnMaster records
	order by t.ChangeID asc

